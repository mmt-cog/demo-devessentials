
publish_sql_projects () {
    # Publish the .dacpac using SqlPackage
    if [ -z "${SQL_PASSWORD}" ]; then
        echo "The SQL_PASSWORD is not set in .env. Fix "
        exit 1
    else
        dotnet publish -c Release "src/mssql/Common/Common.csproj" /p:TargetUser=sa /p:TargetPassword=${SQL_PASSWORD}
        dotnet publish -c Release "src/mssql/Products/Products.csproj" /p:TargetUser=sa /p:TargetPassword=${SQL_PASSWORD}
    fi
}

wait_sqlserver () {
    # Configuration
    HOST="localhost"
    PORT=1433
    RETRY_INTERVAL=15  # seconds
    MAX_RETRIES=30
    USE_SQLCMD="false"

    echo "Waiting for SQL Server to be available at $HOST:$PORT..."

    for ((i=1; i<=MAX_RETRIES; i++)); do
        if nc -z "$HOST" "$PORT"; then
            echo "✅ SQL Server port is open!"
            # Check if SQL Server is ready
            if [ "$USE_SQLCMD" == "true" ]; then
                if /opt/mssql-tools/bin/sqlcmd -S "$HOST,$PORT" -U sa -P "$SQL_PASSWORD" -Q "SELECT 1" &> /dev/null; then
                    echo "✅ SQL Server is ready!"
                    return 0
                else
                    echo "❌ SQL Server is not ready yet. Retrying..."
                    sleep "$RETRY_INTERVAL"
                fi
            else
                echo "Warning: The usage of sqlcmd to check SQL Server availability is disabled. To enable it, install sqlcmd-tools and set USE_SQLCMD=true"
                sleep "$RETRY_INTERVAL" #sleep and give sql server time to expose databases
                return 0
            fi
        else
            echo "⏳ Attempt $i/$MAX_RETRIES: SQL Server not available yet. Retrying in $RETRY_INTERVAL seconds..."
            sleep "$RETRY_INTERVAL"
        fi
    done

    echo "❌ SQL Server did not become available after $((RETRY_INTERVAL * MAX_RETRIES)) seconds."
    exit 1
}

main_call (){
    wait_sqlserver
    publish_sql_projects
}

main_call
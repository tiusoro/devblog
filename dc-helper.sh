#!/bin/bash

# DevBlog Docker Compose Helper
# =============================

COMMAND=$1
TARGET=$2
FOLLOW=$3

show_help() {
    echo "DevBlog Docker Compose Helper"
    echo "============================="
    echo "Usage: ./dc-helper.sh <command> [service]"
    echo ""
    echo "Commands:"
    echo "  up [service]          Start all services, or a specific service"
    echo "  down [service]        Stop all services, or a specific service"
    echo "  build [service]       Build all services, or a specific service"
    echo "  restart [service]     Restart all services, or a specific service"
    echo "  logs [-f] [service]   View logs. Use -f to follow"
    echo "  status [service]      Show status of all or a specific container"
    echo "  seed                  Create admin user (run seeding script)"
    echo "  shell [service]       Open a shell inside a container (web, mongo)"
    echo "  clean                 Stop containers and remove volumes (DESTRUCTIVE)"
    echo "  help                  Show this help message"
    echo ""
    echo "Services: web, mongo, mongo-express"
}

case $COMMAND in
    up)
        docker compose up -d $TARGET
        ;;
    down)
        docker compose stop $TARGET
        ;;
    build)
        docker compose build $TARGET
        ;;
    restart)
        docker compose restart $TARGET
        ;;
    logs)
        # Handle the -f flag logic
        if [ "$TARGET" == "-f" ]; then
            docker compose logs -f $FOLLOW
        else
            docker compose logs $TARGET
        fi
        ;;
    status)
        docker compose ps $TARGET
        ;;
    seed)
        echo "Seeding database..."
        docker compose exec web node create-user-cli.js
        ;;
    shell)
        if [ "$TARGET" == "mongo" ]; then
            docker compose exec mongo mongosh -u admin -p admin123 --authenticationDatabase admin
        elif [ -n "$TARGET" ]; then
            docker compose exec $TARGET sh
        else
            echo "Error: Please specify a service (web or mongo)"
        fi
        ;;
    clean)
        echo "⚠️  WARNING: This will remove all containers and VOLUMES (data loss)!"
        read -p "Are you sure? (y/N): " confirm
        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            docker compose down -v
            echo "Cleanup complete."
        else
            echo "Operation cancelled."
        fi
        ;;
    help|*)
        show_help
        ;;
esac



COMPOSE_FILE := srcs/docker-compose.yml
DATA_DIR ?= $(HOME)/data
export DATA_DIR


up:
	@mkdir -p $(DATA_DIR)/web $(DATA_DIR)/database
	docker compose -f $(COMPOSE_FILE) up --build -d

down:
	docker compose -f $(COMPOSE_FILE) down

clean: down
	docker system prune -f

fclean: down
	docker compose -f $(COMPOSE_FILE) down -v
	docker system prune -af
	sudo chown -R $(USER):$(USER) $(DATA_DIR)
	rm -rf $(DATA_DIR)/web/* $(DATA_DIR)/database/*
	# sudo rm -rf $(DATA_DIR)/web/* $(DATA_DIR)/database/* 2>/dev/null || true

re: fclean all

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

status:
	docker compose -f $(COMPOSE_FILE) ps

all: up

.PHONY: all up down clean fclean re logs status



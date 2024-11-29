raw-data:
	poetry run python src/feature_pipeline/data_sourcing.py --cities chicago bay_area washington_dc columbus --year 2024 

training-data:				
	poetry run python src/feature_pipeline/preprocessing.py --cities washington_dc --year 2024 


# Model Training
train-starts-untuned:
	poetry run python src/training_pipeline/training.py --scenario start --models lasso lightgbm xgboost

train-starts-tuned:
	poetry run python src/training_pipeline/training.py --scenario start --models lasso lightgbm xgboost \
	--tune_hyperparameters --hyperparameter_trials 5

train-ends-untuned:
	poetry run python src/training_pipeline/training.py --scenario end --models lasso lightgbm xgboost

train-ends-tuned:
	poetry run python src/training_pipeline/training.py --scenario end --models xgboost lasso lightgbm \
 	--tune_hyperparameters --hyperparameter_trials 5

train-all: train-starts-untuned train-ends-untuned train-starts-tuned train-ends-tuned


# Backfilling the Feature Store
backfill-features:
	poetry run python src/inference_pipeline/backend/backfill_feature_store.py --scenarios start end --target features 
	
backfill-predictions:
	poetry run python src/inference_pipeline/backend/backfill_feature_store.py --scenarios start end --target predictions
	
backfill-all: backfill-features backfill-predictions	


# Frontend
frontend:
	poetry run streamlit run src/inference_pipeline/frontend/main.py --server.port 8501

start-docker:
	sudo systemctl start docker

image:
	docker build -t divvy-hourly .

container:
	docker run -it --env-file .env -p 8501:8501/tcp divvy-hourly:latest 
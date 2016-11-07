# jawikify

train_extraction:
	mkdir -p ${JSON}
	instance_extraction.sh
	feature_extraction.sh
	svm_rank_learn

train_disambiguate:
	mkdir -p ${JSON}
	instance_extraction.sh
	feature_extraction.sh
	svm_rank_learn

test:
	

evaluate:
	

# jawikify

train_extraction:
	mkdir -p ${JSON}
	instance_extraction.sh
	feature_extraction.sh
	train.sh

train_disambiguate:
	mkdir -p ${JSON}
	instance_extraction.sh
	feature_extraction.sh

test:
	

evaluate:
	

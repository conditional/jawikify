# jawikify

#
# execute options
#
NUM_OF_FOLD = 5
PARAM_TRAIN =
#DRY = --dry-run
BAR = --bar

#
# misc
#
DIR_WORK = work
DIR_LOG  = log
DIR_DATA = data
DIR_MODEL = model

NUM_OF_PARALLEL = -j 20
PARALLEL_OPTIONS = $(NUM_OF_PARALLEL) $(DRY) $(BAR)

#FILE_ABSTRACTION = $(DIR_DATA)/list.txt
FILE_ABSTRACTION = $(DIR_DATA)/list-Name.txt

FILELIST_TRAIN = GSK_filelist.train
FILELIST_DEV = GSK_filelist.dev

GSK_filelist:
	ls /home/work/data/GSK/GSK2014-A/gsk-ene-1.1/bccwj/xml/*/*.xml | shuf > $@

# 1982 files => 1500 250 232
GSK_filelist.train: GSK_filelist
	head -n 1500 $< > $@

GSK_filelist.dev: GSK_filelist
	head -n 1750 $< | tail -n 250  > $@

GSK_filelist.test: GSK_filelist
	head -n 1982 $< | tail -n 232  > $@

md_to_json: GSK_filelist.train
	rm -f $(DIR_WORK)/json/*.json
	cat GSK_filelist.train | /home/matsuda/bin/parallel $(PARALLEL_OPTIONS) "ruby src/md_to_json.rb {} |\
         ruby src/apply_mecab.rb | ruby src/annotate_offset.rb > $(DIR_WORK)/json/{/}.json"

feature_extraction_train:
	mkdir -p $(DIR_WORK)/crfsuite/
	rm -f $(DIR_WORK)/crfsuite/*.f
	rm -f $(DIR_LOG)/*.fe.log
	ls $(DIR_WORK)/json/*.json | parallel $(PARALLEL_OPTIONS) "cat {} |\
         ruby src/md_feature_extraction.rb > $(DIR_WORK)/crfsuite/{/}.f 2> $(DIR_LOG)/{/}.fe.log"
	cat $(DIR_WORK)/crfsuite/*.f > $(DIR_WORK)/train.f

work/train.ff:
	cat $(DIR_WORK)/train.f | ruby src/label_abstraction.rb -h data/list-Name.txt > $(DIR_WORK)/train.ff

model: work/train.ff
	crfsuite learn -m $@ -p max_iterations=20 $< > work/crfsuite.log

# jawikify

#
# execute options
#
NUM_OF_FOLD = 5
PARAM_TRAIN =
#DRY = --dry-run


#
# misc
#
DIR_WORK = work20170113
DIR_LOG  = log
DIR_DATA = data
DIR_MODEL = model

BAR = --bar
NUM_OF_PARALLEL = -j 12
PARALLEL_OPTIONS = $(NUM_OF_PARALLEL) $(DRY) $(BAR)

#FILE_ABSTRACTION = $(DIR_DATA)/list.txt
FILE_ABSTRACTION = $(DIR_DATA)/list-Name.txt

FILELIST_TRAIN = GSK_filelist.train
FILELIST_DEV = GSK_filelist.dev

GSK_filelist:
	ls /home/work/data/GSK/GSK2014-A/gsk-ene-1.1/bccwj/xml/*/*.xml | shuf > $@


# 候補生成のためのデータベース作成
data/master06_candidates.json: data/master06_content.json
	cat $< | ruby src/create_cg_data.rb $@

# 書庫
# few minutes, in maitai
data/master06_candidates.kct: data/master06_candidates.json
	cat $< | ruby src/compile_kb.rb -k mention -t $@

# 3067.94s at maitai
data/master06_content.kch: data/master06_content.json
	cat $< | ruby src/compile_kb.rb -k entry -t $@

# 形態素アノテート 180sec
data/master06_content_mecab_annotated.json: data/master06_content.json
	ruby src/apply_mecab_kb.rb < $< > $@

data/master06_body_markup.txt:
	cp /home/m-suzuki/wikipedia/data/20161101/body_markup.txt $@

data/charanda04.300.kch: data/charanda04.300.gz
	zcat $< | ruby src/compile_vec.rb -t $@

data/master06_content_mecab_annotated.kch: data/master06_content_mecab_annotated.json
	cat $< | ruby src/compile_kb.rb -k entry -t $@

# 知識ベースから作った IDF データベース
# about: 219.72s
data/master06_content_mecab_annotated.idf.json: data/master06_content_mecab_annotated.json
	cat $< | ruby src/calc_idf.rb > $@
# ↑の kch
# 100万エントリ、10秒足らず
data/master06_content_mecab_annotated.idf.kch: data/master06_content_mecab_annotated.idf.json
	cat $< | ruby src/compile_kb.rb -k k -t $@

# BoWだけなら 404s
work/kb.json: data/master06_content_mecab_annotated.json
	ruby src/feature_extraction_from_kb.rb -t word_ids.tsv < $< > $@

# 9490.56s
work/kb.kch: work/kb.json
	cat $< | ruby src/compile_kb.rb -k entry -t $@

# 1982 files => 1500 250 232
#GSK_filelist.train: GSK_filelist
#	head -n 1500 $< > $@
#GSK_filelist.dev: GSK_filelist
#	head -n 1750 $< | tail -n 250  > $@
#GSK_filelist.test: GSK_filelist
#	head -n 1982 $< | tail -n 232  > $@

md_to_json: GSK_filelist
	rm -f $(DIR_WORK)/json/*.json
	cat $< | /home/matsuda/bin/parallel $(PARALLEL_OPTIONS) "ruby src/md_to_json.rb {} |\
         ruby src/apply_mecab.rb | ruby src/annotate_offset.rb > $(DIR_WORK)/json/{/}.json"


md_feature_extraction:
	mkdir -p $(DIR_WORK)/crfsuite/
	rm -f $(DIR_WORK)/crfsuite/*.f
	rm -f $(DIR_LOG)/*.fe.log
	ls $(DIR_WORK)/json/*.json | parallel $(PARALLEL_OPTIONS) "cat {} |\
         ruby src/md_feature_extraction.rb > $(DIR_WORK)/crfsuite/{/}.f 2> $(DIR_LOG)/{/}.fe.log"

work/all.ff:
	cat $(DIR_WORK)/crfsuite/*.f | ruby src/label_abstraction.rb -h data/list-Name20161220.txt > $@

work/chunking.model.all: $(DIR_WORK)/all.ff
	crfsuite learn -m $@ -p max_iterations=500 $< > work/crfsuite.log

test.result: work/chunking.model.all
	cat test2.txt | ruby src/wrap_json.rb |\
        ruby src/apply_mecab.rb |\
        ruby src/annotate_offset.rb |\
        ruby src/md_feature_extraction.rb -t features |\
        ruby src/chunker.rb -m $< -f features -t chunk > result

html_visualize:
	cat test3.txt | bash analyse.sh | ruby src/to_html.rb > ~/public_html/jawikify_proto/index.html


#
# evaluation
#
crf_filelist:
	ls work/crfsuite/*.f | shuf > $@
	head -n 1500 $@ > $@.train
	head -n 1750 $@ | tail -n 250 > $@.dev
	head -n 1982 $@ | tail -n 232 > $@.test

work/train.ff: crf_filelist.train 
	cat $< | parallel --bar "cat {} | ruby src/label_abstraction.rb -h data/list-Name20161220.txt" >> $@

work/dev.ff: crf_filelist.dev
	cat $< | parallel --bar "cat {} | ruby src/label_abstraction.rb -h data/list-Name20161220.txt" >> $@

work/test.ff: crf_filelist.test
	cat $< | parallel --bar "cat {} | ruby src/label_abstraction.rb -h data/list-Name20161220.txt" >> $@

work/chunking.model.all: work/all.ff
	crfsuite learn -m $@ -p max_iterations=500 $< > work/crfsuite.log

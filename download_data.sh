#!/bin/bash

mkdir -p data/
cd data/
wget http://www.cl.ecei.tohoku.ac.jp/~matsuda/jawikify_data/linker.model
wget http://www.cl.ecei.tohoku.ac.jp/~matsuda/jawikify_data/list-Name20161220.txt
wget http://www.cl.ecei.tohoku.ac.jp/~matsuda/jawikify_data/master06_candidates.kct
wget http://www.cl.ecei.tohoku.ac.jp/~matsuda/jawikify_data/master06_content_mecab_annotated.idf.kch
wget http://www.cl.ecei.tohoku.ac.jp/~matsuda/jawikify_data/master06_content.kch
wget http://www.cl.ecei.tohoku.ac.jp/~matsuda/jawikify_data/md.full
wget http://www.cl.ecei.tohoku.ac.jp/~matsuda/jawikify_data/word_ids.tsv
#wget http://www.cl.ecei.tohoku.ac.jp/~matsuda/jawikify_data/

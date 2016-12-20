ruby src/wrap_json.rb |\
        ruby src/apply_mecab.rb |\
        ruby src/annotate_offset.rb |\
        ruby src/md_feature_extraction.rb -t features |\
        ruby src/chunker.rb -m work/chunking.model -f features -t chunk |\
        ruby src/extractor.rb 

# jawikify

jawikify は、日本語テキストに対する wikification を行うためのツールキットです。

関根の拡張固有表現階層に基づく荒い粒度の固有表現抽出と、自動構築したエイリアス辞書、文脈の手がかりに基づくリンカから構成されています。

## requirements

* ruby (最新に近いものを推奨)
* [mecab](http://taku910.github.io/mecab/)
* [kyotocabinet](http://fallabs.com/kyotocabinet/)
* [CRFSuite](http://www.chokkan.org/software/crfsuite/)

また、以下の Ruby ライブラリを必要とします。 近日中に、 bundler 等で一括インストールできるようにする予定です。

* [oj](https://github.com/ohler55/oj)
* [nokogiri](http://www.nokogiri.org/)
* CRFsuite, mecab, kyotocabinet の ruby binding

## getting started

```
$ git clone https://github.com/conditional/jawikify
$ cd jawikify
# モデル・インベントリのデータをダウンロードします。
$ ./download_models.sh
```

## とりあえず解析する

```
# from: http://style.nikkei.com/article/DGXMZO10597750T11C16A2000000
$ cat test.txt
角刈りにパイソン柄のセットアップ、目元には怪しいサングラスをした謎の男性が、「ペンパイナッポーア
ッポーペン」と、テクノ調の曲で歌い踊る約１分間の動画が世界を席巻している。
『PPAP』と名付けられたその動画は、2016年9月28日に米国の人気シンガー、ジャスティン・ビーバーがTwitterで「お気に入り」と紹介したことをきっかけに大ブレイク。
「YouTube週間再生回数ランキング」では、3週連続で日本人初の世界一を記録。
累計は１億回を超える。
その張本人であり、お笑い芸人・古坂大魔王とそっくりな、千葉県出身の53歳のピコ太郎に、『PPAP』の創作秘話について聞いた。
$ cat test.txt | ./jawikify
{"ner":{"sentences":["角刈りにパイソン柄のセットアップ、目元には怪しいサングラスをした謎の男性が
、「ペンパイナッポーアッポーペン」と、テクノ調の曲で歌い踊る約１分間の動画が世界を席巻している。","　『PPAP』と名付けられたその動画は、2016年9月28日に米国の人気シンガー、ジャスティン・ビーバーがTwitterで「お気に入り」と紹介したことをきっかけに大ブレイク。「YouTube週間再生回数ランキング」では、3週連続で日本人初の世界一を記録。累計は１億回を超える。","　その張本人であり、お笑い芸人・古坂大魔王とそっくりな、千葉県出身の53歳のピコ太郎に、『PPAP』の創作秘話について聞いた。"],"extracted":[[["サングラス","Product"],["ペンパイナッポーアッポーペン","Product"]],[["2016年9月2","Product"],["米国","Location"],["ジャスティン・ビーバー","Person"],["日本人","Organization"]],[["お笑い芸人・古坂大魔王","Product"],["千葉県","Location"],["ピコ太郎","Person"]]],"linked":[[{"surface":"サングラス","title":"サングラス","score":"0.2176E1"},{"surface":"ペンパイナッポーアッポーペン","title":null,"score":0.0}],[{"surface":"2016年9月2","title":null,"score":0.0},{"surface":"米国","title":"アメリカ合衆国","score":"0.1937E1"},{"surface":"ジャスティン・ビーバー","title":"ジャスティン・ビーバー","score":"0.2673E1"},{"surface":"日本人","title":"日本人","score":"0.2149E1"}],[{"surface":"お笑い芸人・古坂大魔王","title":null,"score":0.0},{"surface":"千葉県","title":"千葉県","score":"0.2165E1"},{"surface":"ピコ太郎","title":null,"score":0.0}]]}}
$ cat test.txt | ./jawikify | jq '.' | less
```

## 出力の読み方

* `extracted` キー : 関根の拡張固有表現階層に基づく固有表現解析の結果です。現在、以下の11種類の比較的荒い粒度の固有表現が対象です。

```
Product,
Facility,
Location,
Natural_Object,
Organization,
Event,
Disease,
Color,
Person,
Name_Other,
God
```

* `linked` キー: wikification の結果が入ります。現在のところ、以下のキーが含まれています。
  * `surface`: テキスト中の表層です。
  * `title`: 対応するWikipedia記事のタイトル。Wikipedia内に対応先として適切な記事が存在しないと判断した時には `null` が格納されます。
  * `score`: リンク先エンティティの尤もらしさを計算したスコアです。現在は、あまり信頼性がありません :)

## エンティティ辞書のカスタマイズ

~~ 新たにリンク対象としたいエンティティを json 形式で記述し、別名辞書に追加することによって、 Wikipedia に含まれていないエンティティ-表層に対するリンクを行うことが可能です。 ~~

# ToDo

* 入出力形式をマトモにする（いいアイディアがありましたら教えてください）
* エンティティ辞書のカスタマイズ機能を修正、早めにリリースします。

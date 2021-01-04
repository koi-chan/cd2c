class OriginalTable < ApplicationRecord
  belongs_to :user

  # データベースには、カードデッキの定義が改行区切りテキスト形式で保存される
  # → self.definition [String]
  # ウェブインターフェイスから保存するときは CRLF、それ以外の場合はシステム
  # 依存の改行コードになる(はず)

  # Array で定義されたカードの全てを返す
  # @return [Array]
  def elements
    definition.split
  end

  # Array で入力された、カードデッキの要素定義をデータベースに保存する形式に
  # 変換して格納する
  # @param [Array] new_elements カードデッキの要素
  # @return [String]
  def elements=(new_elements)
    self.definition = new_elements.split
  end

  # デッキからランダムに1枚のカードを引く
  # @return [String]
  def drow
    elements.sample
  end
end

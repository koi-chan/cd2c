class TableDeck < ApplicationRecord
  belongs_to :chat_system
  belongs_to :original_table

  # 自身の original_table からカード定義を読み込み、山札を初期化する
  # このときにカードを切るため、引くときにランダマイズする必要はない
  # @raise [StandardError] original_table が設定されていない
  # @return [Array]
  def init_deck
    raise unless original_table
    self.elements = original_table.elements.shuffle
  end

  # Array で山札に残っているカードの全てを返す
  # @return [Array]
  def elements
    rest_contents.split
  end

  # 山札に残っているカードを Array から保存する形式に変換して
  # オブジェクトに格納する
  # 保存処理はされないので別途行なう必要がある
  # @param [Array] new_elements 山札に残っているカード
  # @return [String] 実際にデータベースへ保存される形式(改行区切りテキスト)
  def elements=(new_elements)
    self.rest_contents = new_elements.join("\n")
  end

  # 山札からカードを1枚引く
  # @param [Boolean] save_flag カードを引いた後で保存する
  # @return [String/nil] 保存できなければ nil を返す
  def drow(save_flag = false)
    result, *self.elements = elements

    if save_flag && !self.save
      nil
    else
      result
    end
  end

  # 山札に残っているカードを明示的に混ぜる(引き出される順番を変える)
  # @param [Boolean] save_flag カードを混ぜた後で保存する
  # @return [Array/nil]
  def shuffle(save_flag = false)
    self.elements = elements.shuffle

    if save_flag && !self.save
      nil
    else
      elements
    end
  end
end

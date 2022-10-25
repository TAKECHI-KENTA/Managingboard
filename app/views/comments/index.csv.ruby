require 'csv'

CSV.generate do |csv|
  column_names = %w(タイトル 機嫌 作成日時 メモ記載内容)
  csv << column_names
  @comment.each do |comment|
    column_values = [
      comment.title,
      comment.tention.examination,
      comment.created_at.to_s(:datetime_jp),
      simple_format(comment.description)
      ]
    csv << column_values
  end
end    
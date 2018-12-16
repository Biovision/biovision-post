json.dates @dates do |year, months|
  json.year year
  json.path archive_posts_path(year: year, format: :json)
  json.months months do |month, days|
    json.month month
    json.name t('date.nominative_month_names')[month]
    json.path archive_posts_path(year: year, month: month, format: :json)
    json.days days do |day|
      json.day day
      json.path archive_posts_path(year: year, month: month.to_s.rjust(2, '0'), day: day.to_s.rjust(2, '0'))
    end
  end
end

namespace :posts do
  desc 'Cool down rating of posts'
  task cooldown: :environment do
    Post.connection.execute("update posts set rating = rating * .9 where publication_time <= current_timestamp - interval '3 days'")
  end
end

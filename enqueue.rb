require "redis"
require "json"

redis = Redis.new

(1..4000).each do |i|
    redis.rpush("queue_of_pilars", {id: i, type: "pilar"}.to_json)
end
(1..1000).each do |i|
    redis.rpush("queue_of_panels", {id: i, type: "panel"}.to_json)
end
(1..10).each do |i|
    redis.rpush("queue_of_roads", {id: i, type: "road"}.to_json)
end

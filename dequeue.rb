require "redis"
require "json"

redis = Redis.new

TTL=10

start_time = Time.now

threads = []
2.times do |i|
    threads << Thread.new(i) do |client_uuid|
        while redis.eval("return #redis.call('keys', 'queue_of_*')") > 0 do
            queues = redis.keys("queue_of_*")
            time_now_f = Time.now.to_f
            queues_with_size = queues.map{|q| [q,  redis.zcount("runing_#{q}", time_now_f-TTL, "+inf"), redis.llen(q)]}.sort_by{|_k,no_pods,size|[no_pods,-size]}
            myqueue = queues_with_size[0][0]
            redis.zadd("runing_#{myqueue}", time_now_f, client_uuid)
            puts "Running queue #{myqueue} of size #{redis.llen(myqueue)}"
            sleep 0.5
            puts "When initialized size: #{redis.llen(myqueue)}"
            while x = redis.lpop(myqueue) do
                redis.zadd("runing_#{myqueue}", Time.now.to_f, client_uuid) if time_now_f+(TTL/2) < Time.now.to_f
                sleep 0.001
            end
            redis.zrem("runing_#{myqueue}", client_uuid)
        end
    end
end

threads.each { |thr| thr.join }

puts "Done in #{Time.now-start_time}"
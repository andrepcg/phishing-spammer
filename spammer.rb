#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'ffaker'
require 'faker_credit_card'

CCC = %i[visa mastercard]
PHONE_PREFIX = [91, 92, 93, 95, 96]
FIRST_NAMES = File.readlines('first_names.txt').map(&:strip)
LAST_NAMES = File.readlines('last_names.txt').map(&:strip)
CITIES = File.readlines('cities.txt').map(&:strip)
RUAS = File.readlines('streets.txt').map(&:strip)


def generate_cc
  b = CCC.sample

  number = case b
           when :visa
             Faker::CreditCard::Visa.number
           when :mastercard
             Faker::CreditCard::MasterCard.number
           end
  month = "%02d" % rand(1..12)
  year = rand(20..25)
  { number: number, cvv: rand(0..999), expdate: "#{month}/#{year}", type: b.to_s.capitalize }
end

def generate_phone
  PHONE_PREFIX.sample.to_s + "%07d" % rand(0..9999999)
end

def generate_zip
  "%04d" % rand(1000..5000) + "-" + "%03d" % rand(0..500)
end


def thread_work(endpoint, thread_id)
  data = yield

  # You might also need to change how the data is posted here
  begin
    res = Net::HTTP.post_form(endpoint, data)
  rescue e
    puts "Error: #{e}"
  end
  sleep rand(80..300) / 1000.0 # Sleep for 100-300 ms
end

def help
  puts <<~HELP
  This creates a bunch of requests to submit spam data to scammers and phishing websites

  Usage:
    #{__FILE__} <times to spam> <number of threads>

  Example:
    #{__FILE__} 20 2
  HELP
end


if ((ARGV[0] != '0') && (ARGV[0].to_i.to_s != ARGV[0]&.strip)) ||
   ((ARGV[1] != '0') && (ARGV[1].to_i.to_s != ARGV[1]&.strip))
  help
  Kernel.exit
end
TIMES_TO_SPAM = ARGV[0].to_i
THREAD_COUNT = ARGV[1].to_i


N_PER_THREAD = TIMES_TO_SPAM / THREAD_COUNT

def start_work(endpoint, &block)
  uri = URI.parse(endpoint)
  threads = []
  THREAD_COUNT.times do |thread_id|
    threads << Thread.new do
      N_PER_THREAD.times do |iter|
        thread_work(uri, thread_id) { block.call }
        puts "[THREAD #{thread_id}] Submissions: #{iter + 1}" if iter % 5 == 0
      end
    end
  end

  threads.each(&:join)
end



#
# Change here to your liking
#

ENDPOINT = 'https://particulares.santander.san-totta.org/php/status_1.php'

start_work(ENDPOINT) do
  cc = generate_cc
  cidade = CITIES.sample
  {
    userid: FFaker::Internet.user_name,
    password: FFaker::Internet.password,
    CardType: cc[:type],
    fullname: FIRST_NAMES.sample + " " + LAST_NAMES.sample,
    address: RUAS.sample,
    city: cidade,
    state: cidade,
    zipcode: generate_zip,
    phonenr: generate_phone,
    dob: FFaker::Time.between(Date.new(1980, 01, 01), Date.new(2005, 01, 01)).strftime("%d/%m/%Y"),
    blank: "Blank",
    number: cc[:number].scan(/.{4}/).join("+"),
    expdate: cc[:expdate],
    cvv2: cc[:cvv],
  }
end

puts "Finished!"
puts "Sent #{TIMES_TO_SPAM} fake data"
# Ruby phishing spammer

This is a ruby script to spam (portuguese) phishing websites. It generates data specifically for Portugal (streets, names, cities, etc).


## How to run?

1. `bundle install`
2. `ruby spammer.rb <times to spam> <number of threads>`

The following command will spam the target 100 times using 10 threads:

`ruby spammer.rb 100 10`


## I need to change the data

`start_work` needs to be passed a block. This block is responsible for generating the data.

```ruby
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
```

Also, in line 44 you might need to change how the data is posted. The one included simply uses `Net::HTTP.post_form` to post form data.

## To do

- Pass a list of proxies and use them when doing a request

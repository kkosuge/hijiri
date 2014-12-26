# Hijiri

日本語の文中に含まれる時刻表現をパースします。

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hijiri'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hijiri

## Usage

```ruby
require 'hijiri'

hijiri = Hijiri.parse("1977年8月15日11時42分33秒")
p hijiri.results.first.datetime #=> 1977-08-15 11:42:33 +0900

hijiri = Hijiri.parse("忘れない10年後の8月また出会えるのを…")
p hijiri.results.first.datetime #=> 2024-08-01 00:00:00 +0900

hijiri = Hijiri.parse("あうあうあー１５分後に…")
p hijiri.results.first.datetime #=> 2014-12-27 02:16:23 +0900

Time.now #=> 2014-12-27 02:01:23 +0900
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/hijiri/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

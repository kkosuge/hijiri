require 'active_support/time'
require 'active_support/core_ext/object'
require 'hashie'

module Hijiri
  class Parser
    attr_reader :current, :original_text, :text, :results

    SUB_LIST = {
        /さらいねん|再来年|明後年/     => "#{2.month.from_now.year}年",
        /らいねん|来年|明年|翌年/      => "#{1.month.from_now.year}年",
        /らいげつ|来月/                => "#{1.month.from_now.month}月",
        /あした|あす|明日/             => "#{1.day.from_now.day}日",
        /あさって|みょうごにち|明後日/ => "#{2.days.from_now.day}日",
        /しあさって|明々後日/          => "#{3.days.from_now.day}日"
    }
    CONJ_WORDS = %w(の).join('|')
    TIMER_WORDS = %w(あとに 後 経った たった 経過 けいか).join('|')

    def initialize(text)
      @original_text = text.dup
      @text = text.dup
      @results = []
      @current = Time.now
    end

    def normalize
      %w(０ １ ２ ３ ４ ５ ６ ７ ８ ９).each_with_index do |str, num|
        @text.gsub!(str, num.to_s)
      end
      SUB_LIST.each { |key, value| @text.gsub!(key, value) }
      @text
    end

    def remove_conj
      @text.gsub!(/#{CONJ_WORDS}/, '')
    end

    def pluck
      words = @text
        .scan(/(?:(?:[\d]+年)?(?:[\d]+月)?(?:[\d]+日)?(?:[\d]+時間?)?(?:[\d]+分)?(?:[\d]+秒)?(?:#{TIMER_WORDS})?)+/)
        .delete_if(&:blank?)
        .delete_if{ |word| !word.match(/\d/) }
      @results = words.map{ |result| Hashie::Mash.new(word: result) }
    end

    def scan
      @results.map{ |result| result.datetime = scan_word(result[:word]) }
    end

    def scan_word(word)
      y = word.scan(/([\d]+)年(#{TIMER_WORDS})?/).first
      m = word.scan(/([\d]+)月(#{TIMER_WORDS})?/).first
      d = word.scan(/([\d]+)日(#{TIMER_WORDS})?/).first
      h = word.scan(/([\d]+)時(#{TIMER_WORDS})?/).first
      n = word.scan(/([\d]+)分(#{TIMER_WORDS})?/).first
      s = word.scan(/([\d]+)秒(#{TIMER_WORDS})?/).first

      options = {}
      if word.match(/(?:#{TIMER_WORDS})((?:[\d]+月)?(?:[\d]+日)?)?/)
        point_word = $1
        options[:month] = $1 if point_word.match(/([\d]+)月/)
        options[:day] = $1 if point_word.match(/([\d]+)日/)
      end

      if timer?(word)
        timer_time(y.try(:first),m.try(:first),d.try(:first),h.try(:first),n.try(:first),s.try(:first),options)
      else
        point_time(y.try(:first),m.try(:first),d.try(:first),h.try(:first),n.try(:first),s.try(:first))
      end
    end

    def timer_time(y,m,d,h,n,s,options={})
      if options[:month]
        m = 0
        unless options[:day]
          options[:day] = 1
        end
      end

      d = 0 if options[:day]

      pass = 0
      pass += y.to_i.years.to_i
      pass += m.to_i.month.to_i
      pass += d.to_i.days.to_i
      pass += h.to_i.hours.to_i
      pass += n.to_i.minutes.to_i
      pass += s.to_i.seconds.to_i
      res = @current + pass

      if options.present?
        Time.local(
          res.year,
          options[:month].presence || res.month,
          options[:day].presence || res.day
        )
      else
        res
      end
    end

    def point_time(y,m,d,h,n,s)
      if m && y.nil? && conv_time(y,m,d,h,n,s) < @current
        y = @current.next_year.year
      end
      if d && m.nil? && y.nil? && conv_time(y,m,d,h,n,s) < @current
        m = @current.next_month.month
        return point_time(y,m,d,h,n,s)
      end
      if h && d.nil? && m.nil? && y.nil? && conv_time(y,m,d,h,n,s) < @current
        d = @current.day + 1
        if d > @current.end_of_month.day
          m = @current.next_month.month
          d = 1
        end
        return point_time(y,m,d,h,n,s)
      end
      if n && h.nil? && d.nil? && m.nil? && y.nil? && conv_time(y,m,d,h,n,s) < @current
        h = @current.hour + 1
        h = 1 if h > 24
        return point_time(y,m,d,h,n,s)
      end
      if s && n.nil? && h.nil? && d.nil? && m.nil? && y.nil? && conv_time(y,m,d,h,n,s) < @current
        n = @current.min + 1
        n = 1 if n > 60
        return point_time(y,m,d,h,n,s)
      end

      conv_time(y,m,d,h,n,s)
    end

    def conv_time(y,m,d,h,n,s)
      Time.local(
        y.presence || @current.year,
        m.presence || @current.month,
        d.presence || @current.day,
        h.presence || @current.hour,
        n.presence || @current.min,
        s.presence || @current.sec
      )
    end

    def timer?(word)
      !!word.match(/#{TIMER_WORDS}/)
    end

    def parse
      normalize
      remove_conj
      pluck
      scan
      self
    end
  end
end

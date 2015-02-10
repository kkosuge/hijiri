require 'spec_helper'

describe Hijiri::Parser do
  describe "日時指定" do
    it '年月日時分秒をパースできる' do
      text = "2020年12月25日12時10分10秒"
      time = Time.parse("2020/12/25 12:10:10")
      result = Hijiri::Parser.new(text).parse.results.first.datetime
      expect(result).to eq(time)
    end
    it '年月日時分秒の全組み合わせをパースできる' do
      time = Time.parse("2020/12/25 12:10:10")
      methods = [:year, :month, :day, :hour, :min, :sec]
      combinations = []

      methods.count.times do |i|
        combinations += methods.combination(i+1).to_a
      end

      combinations.each do |methods|
        text = ""
        text << "#{time.year}年"  if methods.find{ |m| m == :year }
        text << "#{time.month}月" if methods.find{ |m| m == :month }
        text << "#{time.day}日"   if methods.find{ |m| m == :day }
        text << "#{time.hour}時"  if methods.find{ |m| m == :hour }
        text << "#{time.min}分"   if methods.find{ |m| m == :min }
        text << "#{time.sec}秒"   if methods.find{ |m| m == :sec }
        result = Hijiri::Parser.new(text).parse.results.first.datetime
        methods.each do |method|
          expect(result.send(method)).to eq(time.send(method))
        end
      end
    end
    it '文章中の日時をパースできる' do
      text = "Ruby 2.2.0 は2014年12月25日にリリースされました"
      time = Time.parse("2014/12/25")
      result = Hijiri::Parser.new(text).parse.results.first.datetime
      [:year, :month, :day].each do |method|
        expect(result.send(method)).to eq(time.send(method))
      end
    end
    it '複数の日付をパースできる' do
      text = "Ruby 2.2.0 は2014年12月25日にリリースされました。今日は2018年1月27日です。"
      times = [Time.parse("2014/12/25"), Time.parse("2018/1/27")]
      results = Hijiri::Parser.new(text).parse.results
      results.each_with_index do |result, index|
        [:year, :month, :day].each do |method|
          expect(result.datetime.send(method)).to eq(times[index].send(method))
        end
      end
    end
    it '日本語の日付をパースできる' do
      text = "明日の天気が気になる"
      time = Time.now + 1.day
      result = Hijiri::Parser.new(text).parse.results.first.datetime
      [:year, :month, :day].each do |method|
        expect(result.send(method)).to eq(time.send(method))
      end
    end
    it '分のみ指定の場合0秒' do
      Timecop.travel(2015, 1, 1, 1, 2, 2) do
        text = "3分"
        result = Hijiri::Parser.new(text).parse.results.first.datetime
        expect(result.sec).to eq(0)
      end
    end
    it '時間のみ指定の場合0分' do
      Timecop.travel(2015, 1, 1, 1, 2) do
        text = "12時"
        result = Hijiri::Parser.new(text).parse.results.first.datetime
        expect(result.min).to eq(0)
      end
    end
    it '日のみ指定の場合0時0分' do
      Timecop.travel(2015, 1, 1, 1, 2) do
        text = "2日"
        result = Hijiri::Parser.new(text).parse.results.first.datetime
        expect(result.hour).to eq(0)
        expect(result.min).to eq(0)
      end
    end
    it '付きのみ指定の場合1日0時0分' do
      Timecop.travel(2015, 1, 1, 1, 2) do
        text = "12月"
        result = Hijiri::Parser.new(text).parse.results.first.datetime
        expect(result.month).to eq(12)
        expect(result.day).to eq(1)
        expect(result.hour).to eq(0)
        expect(result.min).to eq(0)
      end
    end
    it '年のみ指定の場合1日0時0分' do
      Timecop.travel(2015, 1, 1, 1, 2) do
        text = "2016年"
        result = Hijiri::Parser.new(text).parse.results.first.datetime
        expect(result.month).to eq(1)
        expect(result.day).to eq(1)
        expect(result.hour).to eq(0)
        expect(result.min).to eq(0)
      end
    end
  end
  describe "〜時間後" do
    it '1時間後' do
      text = "1時間後"
      time = Time.now + 1.hour
      result = Hijiri::Parser.new(text).parse.results.first.datetime
      [:year, :month, :day, :hour, :min, :sec].each do |method|
        expect(result.send(method)).to eq(time.send(method))
      end
    end
    it '1年経過した時' do
      text = "1年経過した時"
      time = Time.now + 1.year
      result = Hijiri::Parser.new(text).parse.results.first.datetime
      expect(result.year).to eq(time.year)
    end
    it '全角でもパースできる' do
      text = "１０分後"
      time = Time.now + 10.minute
      result = Hijiri::Parser.new(text).parse.results.first.datetime
      [:year, :month, :day, :hour, :min].each do |method|
        expect(result.send(method)).to eq(time.send(method))
      end
    end
    it '文章中の時間をパースできる' do
      text = "えーと１５分経ったら教えて"
      time = Time.now + 15.minute
      result = Hijiri::Parser.new(text).parse.results.first.datetime
      [:year, :month, :day, :hour, :min].each do |method|
        expect(result.send(method)).to eq(time.send(method))
      end
    end
    it '文章中の時間をパースできる' do
      text = "えーと１５分経ったら教えて"
      time = Time.now + 15.minute
      result = Hijiri::Parser.new(text).parse.results.first.datetime
      [:year, :month, :day, :hour, :min].each do |method|
        expect(result.send(method)).to eq(time.send(method))
      end
    end
    it '10年後の8月' do
      text = "10年後の8月になったら教えて"
      time = Time.now + 10.years
      result = Hijiri::Parser.new(text).parse.results.first.datetime
      expect(result.year).to eq(time.year)
      expect(result.month).to eq(8)
      expect(result.day).to eq(1)
    end
    it '10年後の20日' do
      text = "10年後の20日になったら教えて"
      time = Time.now + 10.years
      result = Hijiri::Parser.new(text).parse.results.first.datetime
      expect(result.year).to eq(time.year)
      expect(result.day).to eq(20)
    end
    it '10年後の8月20日' do
      text = "10年後の8月20日になったら教えて"
      time = Time.now + 10.years
      result = Hijiri::Parser.new(text).parse.results.first.datetime
      expect(result.year).to eq(time.year)
      expect(result.month).to eq(8)
      expect(result.day).to eq(20)
    end
    it '複数の時間をパースできる' do
      text = "えーと１５分経ったら教えて。あと１年後"
      result = Hijiri::Parser.new(text).parse.results
      time = Time.now + 15.minute
      [:year, :month, :day, :hour, :min].each do |method|
        expect(result.first.datetime.send(method)).to eq(time.send(method))
      end
      expect(result[1].datetime.year).to eq(time.next_year.year)
    end
  end
end

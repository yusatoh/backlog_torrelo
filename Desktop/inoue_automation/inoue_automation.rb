#crontab
#10 00 1 * * cd /home/centos/tools//home/centos/tools/inoue_automation/ && ~/.rbenv/shims/ruby inoue_automation.rb


require 'mysql2'
require 'date'
require 'json'
require 'mail'


options = {
  :address => "localhost",
  :port => 25,
  :authentication => "plain",
  :enable_starttls_auto => true
}

Mail.defaults do
  delivery_method :smtp, options
end


def select_smartparkdb


  File.open('./servers.json','r') do |test|
    @servers = JSON.load(test)
   # p @servers
  end
  
  
  @servers.each do |hostname, portnum|
    @csv_hostname = hostname
    client = Mysql2::Client.new(:host => hostname, username:"smartpark", password: "smartpark", database: "smartparkdb_phase3", port:portnum, :flags => Mysql2::Client::MULTI_STATEMENTS,:as => :array)
    sql = ''
    File.open("./select_smartparkdb.sql","r") do |f|
     sql = f.read
    end
    result = client.query(sql)
    #headers = result.fields
    result_60 = result.to_a
        while client.next_result
          result_120 = client.store_result.to_a
        end

    
    d =  Date.today << 1
    lastmonth = d.strftime("%Y年 %m月")

    result_60_body = result_60[0]
    result_120_body = result_120[0]
  #today_yyyydd = d.year.to_s + "年" + d.month.to_s + "月"

  mail = Mail.new do
    from 'y_satou@pitdesign.jp'
    to 'a_nakaide@pitdesign.jp'
    cc 'solutiong@pitdesign.jp','pit_sysoperation@pitdesign.jp'
    subject "きんのぶた大東・井上産婦人科様#{lastmonth}のサービス券使用数について"
    body "#{lastmonth}のサービス券使用枚数は下記の通りです。\n\r60分券： #{result_60_body}\n120分券：#{result_120_body} \n\rどうぞよろしくお願いします。"
  end
  mail.deliver!

end
end

select_smartparkdb


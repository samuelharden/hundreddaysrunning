require 'uri'
require 'net/http'
require 'nokogiri'
require 'strava/api/v3'
require 'active_support'


    http = Net::HTTP.new('app.100daysofrunning.in', '80')
    puts "=========Doing Login================"
    data = 'username=gauravarora.daiict@gmail.com'  + '&password=04121989' ;
    headers = {
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
    path= '/customApp/login';
    resp, data = http.post(path, data, headers)

    cookie = resp.response['set-cookie'].split('; ')[0]

    puts 'Code = ' + resp.code
    puts 'Message = ' + resp.message
    resp.each {|key, val| puts key + ' = ' + val}
    puts data
    puts cookie
    puts "=============Submitting Run for today================="

    uri = URI('http://app.100daysofrunning.in/customApp/logDailyRun.htm')
    req = Net::HTTP::Get.new(uri)
    req['cookie'] = cookie
    resp = http.request(req)

    # Output on the screen -> we should get either a 302 redirect (after a successful login) or an error page
    puts 'Code = ' + resp.code
    puts 'Message = ' + resp.message
    resp.each {|key, val| puts key + ' = ' + val}
    fragment = Nokogiri::HTML(resp.body)
    runnerId = fragment.at('input[name="runnerId"]')['value']
    puts "runnerId"
    puts runnerId
    date = "2017-06-11"
    start_date = DateTime.parse(date+' 00:00:00').to_time
    end_date = DateTime.parse(date+' 23:59:59').to_time
    puts start_date
    puts end_date
   client = Strava::Api::V3::Client.new(:access_token => "64cb3f23dd6895216bccd6c57eee08c2fb999534")
   activities = client.list_athlete_activities(:after => start_date.to_f, :before => end_date.to_f)
   puts activities
   distance = 0;
   seconds = 0;
   links = 'Links';   
   activities.each do |child|
	distance += child['distance']
	seconds += child['moving_time']
	links += ';'
	links += 'https://www.strava.com/activities/' + child['id'].to_s
   end
   distance = distance/1000
   puts distance
   puts seconds
   puts links
   puts Time.at(seconds).utc.hour
   puts Time.at(seconds).utc.min
   puts Time.at(seconds).utc.sec
    data = 'runnerId='+runnerId + '&runDate=' + date  + '&distance=' + distance.to_s + '&hours=' + Time.at(seconds).utc.hour.to_s + '&minutes=' + Time.at(seconds).utc.min.to_s + '&seconds=' + Time.at(seconds).utc.sec.to_s + '&runLogDetails=' + links;
    headers = {
      'cookie' => cookie,
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
    path= '/customApp/saveDailyRun.htm';
    resp, data = http.post(path, data, headers)


    puts 'Code = ' + resp.code

    puts "=========Showing Runs================"
    uri = URI('http://app.100daysofrunning.in/customApp/showDailyRuns.htm')
    req = Net::HTTP::Get.new(uri)
    req['cookie'] = cookie
    resp = http.request(req)

    # Output on the screen -> we should get either a 302 redirect (after a successful login) or an error page
    puts 'Code = ' + resp.code
    puts 'Message = ' + resp.message
    resp.each {|key, val| puts key + ' = ' + val}
#    puts resp.body
    fragment = Nokogiri::HTML(resp.body)
   # puts fragment
    rows = fragment.search('tr')
    details = rows.each do |row|
      #puts row
      detail = {}
	[
	  [:date, 'td[1]/text()'],
	  [:distance, 'td[2]/text()'],
	  [:time, 'td[3]/text()'],
	  [:link, 'td[4]/text()'],
	].each do |name, xpath|
	  detail[name] = row.at_xpath(xpath).to_s.strip
        end
     print "{ day: '" + detail[:date] + "' } , "
    end
    puts details
 

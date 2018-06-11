require 'sinatra'
require 'sinatra/reloader'
require 'uri'
require 'rest-client'
require 'nokogiri'
require 'csv'

get '/' do
    erb :index
end


# 1. Crawling 복습하기
get '/webtoon' do
    case params[:method]
    when "naver"
        url = RestClient.get("https://comic.naver.com/webtoon/weekday.nhn")
        result = Nokogiri::HTML(url)
        wt = result.css("a")
        #content > div.list_area.daily_all > div.col.col_selected > div > ul > li:nth-child(1) > a
        @wt = wt.text
        puts @wt
    when "daum"
        
    end
    
    # 받아온 데이터를 저장할 배열 생성
    toons = []
    # 웹툰 데이터를 받아올 url파악 및 요청 보내기
    url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon?timeStamp=1528676809473"
    result = RestClient.get(url)
    # json형태로 응답된 데이터를 해쉬형태로 바꾸기
    webtoons = JSON.parse(result)
    # 해쉬에서 웹툰 리스트에 해당하는 부분 순환문으로 뽑아내기
    webtoons["data"].each do |toon|
        # 웹툰 제목
        title = toon["title"]
        # 웹툰 이미지 주소
        image = toon["thumbnailImage2"]["url"]
        # 웹툰을 볼 수 있는 링크
        link = "http://webtoon.daum.net/webtoon/view/#{toon['nickname']}"
        # 필요한 부분을 분리해서 처음 만든 배열에 넣기
        toons << {"title" => title,
                    "image" => image,
                    "link" => link
                    }
    end
    # 완성된 배열 중 3개의 웹툰만 랜덤 추출
    @daum_webtoon = toons.sample(3)
    erb :webtoon
end


# 2. CSV 파일 확인 및 생성
get '/check_file' do
    # unless = if not : 파일이 있니? 
    unless File.file?('./webtoon.csv')
                # 받아온 데이터를 저장할 배열 생성
        toons = []
        # 웹툰 데이터를 받아올 url파악 및 요청 보내기
        url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon?timeStamp=1528676809473"
        result = RestClient.get(url)
        # json형태로 응답된 데이터를 해쉬형태로 바꾸기
        webtoons = JSON.parse(result)
        # 해쉬에서 웹툰 리스트에 해당하는 부분 순환문으로 뽑아내기
        webtoons["data"].each do |toon|
            # 웹툰 제목
            title = toon["title"]
            # 웹툰 이미지 주소
            image = toon["thumbnailImage2"]["url"]
            # 웹툰을 볼 수 있는 링크
            link = "http://webtoon.daum.net/webtoon/view/#{toon['nickname']}"
            # 필요한 부분을 분리해서 처음 만든 배열에 넣기
            toons << [title, image, link]
        end
        # CSV 파일을 새로 생성하는 코드
        CSV.open('./webtoon.csv', 'w+') do |row|
            #크롤링한 웹툰 데이터 CSV에 삽입
            toons.each_with_index do |toon, index|
                row << [index.to_i+1, toon[0], toon[1], toon[2]]
            end
        end
        erb :check_file
    else
        # 존재하는 CSV 파일을 불러오는 코드
        @webtoons = []
        CSV.open('./webtoon.csv', 'r+').each do |row|
            @webtoons << row
        end
        erb :webtoons
    end
end


# 3. wild card
get '/board/:name' do
   puts params[:name] 
end
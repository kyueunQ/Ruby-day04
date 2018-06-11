## 1. Crawling 복습

### /webtoon

##### -  현재 다음 webtoon만 진행함

1. 웹툰, 네이버 웹툰에서 웹툰 데이터를 크롤링함

2. 두 사이트에서 받아온 데이터 형태를 일치시킨다.  

   데이터는 웹툰제작, 썸네일 이미지, 웹툰을 볼 수 있는 링크

   (다음은 JSON, 네이버는 html)

3. 랜덤으로 비복원 추출을 하려면 배열 형태로 데이터를 만든다.

4. 배열 안에 있는 웹툰 1개의 데이터는 해쉬(딕셔너리)형태로 만든다.

5. 웹툰 3개를 뽑아서 <table> 태그를 이용해서 표로 보여준다.

<추가과제>

- 각 요일 별로 추출하기 

- 버튼에 일~토요일까지 버튼을 만들고 /webtoon?day=mon 의 형태로 접속하면 월요일 웹툰 중에서만 샘플링 하도록 함

  

  *views/webtoon.erb*

  ```erb
  <h2>Webtoon<h2>
  <table>
      <thead>
          <th>이미지</th>
          <th>제 목</th>
          <th>링 크</th>
      </thead>
      <tbody>
          <% @daum_webtoon.each do |toon| %>
          <tr>
              <td><img src="<%= toon["image"] %>"></td>
              <td><%= toon["title"] %></td>
              <td><a href="<%= toon["link"] %>">보러가기</a></td>
          </tr>
          <% end %>
      </tbody>
  </table>
  ```

  

  *app.rb*

  ```ruby
  require 'sinatra'
  require 'sinatra/reloader'
  require 'uri'
  require 'rest-client'
  require 'nokogiri'
  require 'csv'
  ```

  ```ruby
  get '/webtoon' do
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
  ```

  - 크롤링 할 사이트 http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon?timeStamp=1528676809473 을 검색하면 자료가 저장된 구조를 확인할 수 있음 

    (데이터가 복잡하게 나열되어 있을 경우, 웹스토어에서 'JSON Formatter'를 설치)

    ```html
    {...,
    "data": [
    {
    "id": 1469,
    "nickname": "gzstreet",
    "webtoonType": "series",
    "title": "곤조 스트릿",
    "finishYn": "N",
    "thumbnailImage2": {
    ...}, }
    ```

  - key가 "data", value가 배열로 이뤄져 있음 (한 웹툰마다 딕셔너리 형태로 정보가 담겨져 있음)





## 2. CSV 파일 확인 및 생성

### /check_file

(위의 웹툰 데이터를 기반으로 진행함)

1. data는 기본적으로 한 번만 받아온다.

2. 이미 데이터가 있으면 전체 목록을 불러오는 '/'로 redirect 해준다.

3. 만약 데이터가 없으면 모든 정보를 저장하는 .csv 파일을 새로 만들어 줌

   

*webtoons.erb*

```ruby
<table class="table table-hover">
    <thead>
        <th>글번호</th>
        <th>이미지</th>
        <th>제 목</th>
        <th>링 크</th>
    </thead>
    <tbody>
        <% @webtoons.each do |toon| %>
        <tr>
            <td><%= toon[0] %></td>
            <td><img src="<%= toon[2] %>"></td>
            <td><%= toon[1] %></td>
            <td><a href="<%= toon[3] %>">보러가기</a></td>
        </tr>
        <% end %>
    </tbody>
</table>
```



*check_file.erb*

```ruby
<h1> CSV 파일이 생성되었습니다.</h1>
```



*app.rb*

```ruby
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
```

 - CSV.open mode로 "r", "r+", "w", "w+", "a", "a+", "b", "t" 등이 있음

   (https://stackoverflow.com/questions/3682359/what-are-the-ruby-file-open-modes-and-options)

   - w+ : Read-write 기능(w의 경우 Write-only)
   - r+: Read-write 기능 (r의 경우 Read-only)

- CSV.read( )와 CSV.open( )의 차이점은?

  - 

- toons**.each_with_index** do |toon, index|
                  row << [index.to_i+1, toon[0], toon[1], toon[2]]
              end

  : 두 개의 인자를 호출하여 사용함

  



## 3. Layout

*layout.erb*

```html
<html>
    <head>
        <title>상단에 표기되는 부</title>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
        <!-- client에게 보여줄 부분 -->
        <%= yield %>
    </head>
        
</html>
```

- <%= yield %> :  layout.erb 가 존재하면 다른 view 파일보다 먼저 실행되는데, title을 보여준 뒤 yied를 통해 view 내용을 보여준 후 layout으로 다시 돌아옴





```ruby
*기억해요
- 루비는 모든 것이 객체이고, 모든 것이 method이다.
- gem uninstall sinatra 
   : 2.0.2버전과 2.0.3버전이 동시에 깔려 충돌을 일으킬 경우, 해당 명렬어를 통해 하나를 제거하면 정상 작동됨
```
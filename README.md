# 💄MOTD
한성대학교 2025-1 ios프로그래밍 기말 미니프로젝트 (25T1007 김희주)
<br/><br/>

## 프로젝트 개요
<h3>1) 프로젝트 소개</h3>

화장품을 기록하고 기록을 확인할 수 있는 앱

<br/>

<h3>2) 프로젝트 기획 배경 및 필요성</h3>

* 코스메틱 덕후, 일명 코덕들은 오늘 어떤 화장품으로 화장했고 사용감이 어떤지 sns에 정보를 남기고는 한다. 하지만 정리되지 않은 기록들은 한 눈에 찾아보기가 어렵다.
* 메이크업은 특히 날씨에 영향을 많이 받는다. 하지만 sns에 메이크업을 기록할 때 정확한 기온과 습도는 같이 기록하지 않기 때문에, 날씨 정보와 함께 메이크업 기록을 쉽게 볼 수 있도록 한다.

<br/>

<h3>3) 프로젝트 목표</h3>

* 메이크업 기록
  - 외출 전 뿐만 아니라 지속력 확인을 위해 귀가 후의 메이크업까지 기록할 수 있게 한다.
* 기록 확인
  - 원하는 날짜의 메이크업 기록을 확인할 수 있다.
  - 원하는 날씨의 메이크업 기록을 확인할 수 있다.

<br/>

## 프로젝트 설명

<h3>1) 사용 기술</h3>

<h4>📱 ios (Xcode)</h4>

|구분|설명|
|---------|-------------|
|UIKit|전체 UI 구성|
|FSCalendar|달력 뷰 구성|
|CoreLocation|위치 정보 활용|
|OpenWeatherMap API|날씨 정보 활용|
|FirebaseFirestore|데이터 저장 및 불러오기|

<br>
<h4>📚이외</h4>

|구분|설명|
|---------|-------------|
|Firebase|화장품 목록 및 사용자 기록 저장|
|Python|화장품 목록 크롤링|

<br/>

<h3>2) 프로젝트 구조</h3>
<img width="786" alt="Image" src="https://github.com/user-attachments/assets/c6036757-cfb7-41f7-a5d4-c5d8aec725cd" />
<br/>

<h3>3) 매뉴얼</h3>

- 앱 실행 후 메인 화면에서 현재 기온과 습도 확인 가능
- "외출 전 메이크업 기록하기" 및 "귀가 후 메이크업 기록하기"의 카테고리 중 기록하고 싶은 버튼 클릭
  * "브랜드"와 "제품명"을 검색하여 선택
  * 질문에 따른 만족도 선택
  * 저장하기 클릭 후 확인 클릭
- "메이크업 기록 보기"에서 원하는 기록 확인 방식 선택
  * 날짜: 달력에서 원하는 날짜 선택 후, 아래에서 카테고리 선택
  * 날씨: 기온과 습도 선택 후, 아래에서 카테고리 선택

 <br/>

<h3>4) 특이사항</h3>

- 질문과 만족도 항목은 카테고리마다 다름
- 해당하는 조건에 기록이 없으면 "기록이 없습니다"라고 뜸
- 날짜는 오늘, 기온과 습도는 현재 위치에 해당하는 값이 디폴트로 선택되어 있음
- 기온과 습도를 선택하면, 기온은 +-2도, 습도는 +-5% 범위 내의 기록 중 가장 최신 기록을 불러옴


<br/>

<h3>5) 결과물</h3>

- 로딩 화면

![Image](https://github.com/user-attachments/assets/249add6c-26e8-4383-9493-fe058ca54868)

- 메인 화면

![Image](https://github.com/user-attachments/assets/e3158e69-c763-41bc-8129-82dc06d391e8)

- 기록 화면

![Image](https://github.com/user-attachments/assets/dc8b0e16-9ce2-47ed-9329-f807f0cc8614)
![Image](https://github.com/user-attachments/assets/9c79c3fc-63aa-44b5-9177-6d83cbb8c0ae)
![Image](https://github.com/user-attachments/assets/4724dfa4-58a3-4ebf-8951-0b4f9d90c350)
![Image](https://github.com/user-attachments/assets/f91ff1f0-fcb2-449d-b75f-fba706cf5a45)
![Image](https://github.com/user-attachments/assets/ce5739a7-d975-4c7d-81c8-3056810b4d5f)

- 기록 확인 화면

![Image](https://github.com/user-attachments/assets/6030048e-71f3-42c7-bcab-6da83640c5d5)
![Image](https://github.com/user-attachments/assets/9500a5ea-dc86-47e9-8409-fd3cfc607141)
![Image](https://github.com/user-attachments/assets/32605548-798b-4a90-863f-cc13d533c53b)
![Image](https://github.com/user-attachments/assets/31214c08-3ead-4afb-90e5-44efe6235723)
<br/>

<h3>6) 소개 영상</h3>

[![Video Label](http://img.youtube.com/vi/Ier0guT5iQI/0.jpg)](https://youtu.be/Ier0guT5iQI)

링크: https://www.youtube.com/watch?v=Ier0guT5iQI

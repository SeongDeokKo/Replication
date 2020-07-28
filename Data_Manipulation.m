clc
clear

% 경제학부 2020-38259 고성덕 
% 거시경제학 특수연구 과제 1

%% 국민계정 데이터 불러오기 
t = [1980.25:0.25:2020]';
Data = xlsread('KOR_Data','Sheet1') ;

Y = Data(:,1)*10^9 ; % 분기별 실질 GDP 
C = Data(:,2)*10^9;  % 분기별 민간 소비지출
G = Data(:,3)*10^9 ; % 분기별 정부 소비지출
I = Data(:,4)*10^9 ; % 분기별 총자본형성(투자)
X = Data(:,5)*10^9 ; % 분기별 수출
M = Data(:,6) *10^9; % 분기별 수입
CD = Data(:,7) *10^9; % 분기별 가계의 내구재 소비  

% 위 데이터들은 모두 십억원 단위 따라서 10^9 곱해주는 작업 
%% Sales Tax 계산하기 

Tax_Data = xlsread('KOR_Tax','Sheet1');
Tax = Tax_Data(:,2)*0.01 ;     

Tax_Rate= interp1(1:size(Tax,1),Tax,1.25:0.25:size(Y,1)/4+1,'pchip','extrap')';

Sales_Tax = Tax_Rate .* Y ; % Sales Tax 계산 
%% 인구데이터 계산하기 
Pop_Data = xlsread('KOR_Pop','Sheet1');

Pop_QTR = interp1(1:size(Pop_Data,1),Pop_Data,1.25:0.25:size(Y,1)/4+1,'pchip','extrap'); 
Pop_QTR = 1000*Pop_QTR';

%% 고용데이터 

EMP_Data = xlsread('KOR_Emp','Sheet1');

T = EMP_Data(:,1) ;
ET = EMP_Data(:,2) ;  
HRS = EMP_Data(:,3)/4 ;

% 2019년 데이터가 존재하지 않기 때문에 이에 대해서는 
% Time Linear Model을 통해서 이를 이용해서 값을 추정. 
% 근로자당 노동시간이 연간이기 때문에 분기별로 만들기 위해서 1/4 로 조정 
Beta = OLS(HRS(1:39),T(1:39), 1) ;
HRS(end) =Beta(1) + T(40)*Beta(2) ; 

ET_QTR = interp1(1:size(ET,1),ET,1.25:0.25:size(Y,1)/4+1,'pchip','extrap')'; 
HRS_QTR = interp1(1:size(HRS,1),HRS,1.25:0.25:size(Y,1)/4+1,'pchip','extrap')'; 

%% 소비자의 내구재로부터 축적되는 자본 

Delta_D = 1-(1-0.25)^(1/4); % Depreciation Rate of Durable Goods 
KCD = zeros(size(CD,1),1);
KCD(1) = 16*CD(1);
for i = 1:size(CD,1)-1
    KCD(i+1) = (1-Delta_D)*KCD(i)+CD(i);
end

%% 논문에 맞게 Adjust 시키기 

ADJ_Y = Y - Sales_Tax + 0.01*KCD + Delta_D*KCD ;
ADJ_C = C - CD - (C-CD).* Tax_Rate + 0.01*KCD + Delta_D*KCD ;
ADJ_G = G + X -M ; 
H = HRS_QTR .* ET_QTR ;
ADJ_X = CD + I - CD/C*Tax_Rate ; 
%%

ypc = ADJ_Y./Pop_QTR;
hpc = H./Pop_QTR/1300;
xpc = ADJ_X./Pop_QTR;
gpc = ADJ_G./Pop_QTR;
cpc = ADJ_C./Pop_QTR;
iP = Pop_QTR ; 

K = xlsread('KOR_Cap','Sheet1');

K_QTR =  interp1(1:size(K,1),K,1.25:0.25:size(ypc,1)/4+1,'pchip','extrap')';
% Captial Stock interpolated 
% 한국은행 데이터는 10억 단위 
kpc = K_QTR./iP * 10^9; % Per capita Capital Stock 

save('data.mat')

% end program

clc
clear

% �����к� 2020-38259 ���� 
% �Žð����� Ư������ ���� 1

%% ���ΰ��� ������ �ҷ����� 
t = [1980.25:0.25:2020]';
Data = xlsread('KOR_Data','Sheet1') ;

Y = Data(:,1)*10^9 ; % �б⺰ ���� GDP 
C = Data(:,2)*10^9;  % �б⺰ �ΰ� �Һ�����
G = Data(:,3)*10^9 ; % �б⺰ ���� �Һ�����
I = Data(:,4)*10^9 ; % �б⺰ ���ں�����(����)
X = Data(:,5)*10^9 ; % �б⺰ ����
M = Data(:,6) *10^9; % �б⺰ ����
CD = Data(:,7) *10^9; % �б⺰ ������ ������ �Һ�  

% �� �����͵��� ��� �ʾ�� ���� ���� 10^9 �����ִ� �۾� 
%% Sales Tax ����ϱ� 

Tax_Data = xlsread('KOR_Tax','Sheet1');
Tax = Tax_Data(:,2)*0.01 ;     

Tax_Rate= interp1(1:size(Tax,1),Tax,1.25:0.25:size(Y,1)/4+1,'pchip','extrap')';

Sales_Tax = Tax_Rate .* Y ; % Sales Tax ��� 
%% �α������� ����ϱ� 
Pop_Data = xlsread('KOR_Pop','Sheet1');

Pop_QTR = interp1(1:size(Pop_Data,1),Pop_Data,1.25:0.25:size(Y,1)/4+1,'pchip','extrap'); 
Pop_QTR = 1000*Pop_QTR';

%% ��뵥���� 

EMP_Data = xlsread('KOR_Emp','Sheet1');

T = EMP_Data(:,1) ;
ET = EMP_Data(:,2) ;  
HRS = EMP_Data(:,3)/4 ;

% 2019�� �����Ͱ� �������� �ʱ� ������ �̿� ���ؼ��� 
% Time Linear Model�� ���ؼ� �̸� �̿��ؼ� ���� ����. 
% �ٷ��ڴ� �뵿�ð��� �����̱� ������ �б⺰�� ����� ���ؼ� 1/4 �� ���� 
Beta = OLS(HRS(1:39),T(1:39), 1) ;
HRS(end) =Beta(1) + T(40)*Beta(2) ; 

ET_QTR = interp1(1:size(ET,1),ET,1.25:0.25:size(Y,1)/4+1,'pchip','extrap')'; 
HRS_QTR = interp1(1:size(HRS,1),HRS,1.25:0.25:size(Y,1)/4+1,'pchip','extrap')'; 

%% �Һ����� ������κ��� �����Ǵ� �ں� 

Delta_D = 1-(1-0.25)^(1/4); % Depreciation Rate of Durable Goods 
KCD = zeros(size(CD,1),1);
KCD(1) = 16*CD(1);
for i = 1:size(CD,1)-1
    KCD(i+1) = (1-Delta_D)*KCD(i)+CD(i);
end

%% ���� �°� Adjust ��Ű�� 

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
% �ѱ����� �����ʹ� 10�� ���� 
kpc = K_QTR./iP * 10^9; % Per capita Capital Stock 

save('data.mat')

% end program

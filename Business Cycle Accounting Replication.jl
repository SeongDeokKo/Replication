using Plots
using StatsFuns
using Distributions, Interpolations
using DataFrames, XLSX
using Dierckx
include("OLS.jl")
Cap_Data = DataFrame(XLSX.readtable("KOR_Cap.xlsx","Sheet1" ,infer_eltypes = true)...);
KOR_Data = DataFrame(XLSX.readtable("KOR_Data.xlsx","Sheet1" ,infer_eltypes = true)...);
Pop_Data = DataFrame(XLSX.readtable("KOR_Pop.xlsx","Sheet1" ,infer_eltypes = true)...);
Emp_Data = DataFrame(XLSX.readtable("KOR_Emp.xlsx","Sheet1" ,infer_eltypes = true)...);
Tax_Data = DataFrame(XLSX.readtable("KOR_Tax.xlsx","Sheet2",infer_eltypes = true,)...);
Y = KOR_Data[:,2]*10^9 ; # 분기별 실질 GDP 
C = KOR_Data[:,3]*10^9;  # 분기별 민간 소비지출
G = KOR_Data[:,4]*10^9 ; # 분기별 정부 소비지출
I = KOR_Data[:,5]*10^9 ; # 분기별 총자본형성(투자)
X = KOR_Data[:,6]*10^9 ; # 분기별 수출
M = KOR_Data[:,7] *10^9; # 분기별 수입
CD = KOR_Data[:,8] *10^9; # 분기별 가계의 내구재 소비  
# Tax 계산
Tax = Tax_Data[:,2]*0.01 ; 
sp1 = Spline1D(1:1:40, Tax, k = 3, bc = "extrapolate");
Tax_Rate = sp1(1.25:0.25:160/4+1);
Sales_Tax = Tax_Rate .* Y ; # Sales Tax 계산 
## 인구데이터 계산하기 
Pop = Pop_Data.Pop ;
sp2 = Spline1D(1:size(Pop,1),Pop, k = 3, bc = "extrapolate" )
Pop_QTR = sp2(1.25:0.25:size(Y,1)/4+1); 
Pop_QTR = 1000*Pop_QTR;
## 고용데이터 
T = Emp_Data.Time ;
ET = Emp_Data.ET ;  
HRS = Emp_Data.HRS /4 ;

# 2019년 데이터가 존재하지 않기 때문에 이에 대해서는 
# Time Linear Model을 통해서 이를 이용해서 값을 추정. 
# 근로자당 노동시간이 연간이기 때문에 분기별로 만들기 위해서 1/4 로 조정 
Beta, ~ = OLS(HRS[1:39],T[1:39] ; add_constant = 1) ;

HRS[end] = Beta[1] + T[40]*Beta[2] ; 
sp3 = Spline1D(1:size(ET,1),ET, k=3, bc ="extrapolate")
sp4 = Spline1D(1:size(HRS,1),HRS, k=3, bc ="extrapolate")
ET_QTR = sp3(1.25:0.25:size(Y,1)/4+1); 
HRS_QTR = sp4(1.25:0.25:size(Y,1)/4+1); 
## 소비자의 내구재로부터 축적되는 자본 

Delta_D = 1-(1-0.25)^(1/4); # Depreciation Rate of Durable Goods 
KCD = zeros(size(CD,1),1);
KCD[1] = 16*CD[1];
for i = 1:size(CD,1)-1
    KCD[i+1] = (1-Delta_D)*KCD[i]+CD[i]
end

## 논문에 맞게 Adjust 시키기 

ADJ_Y = Y - Sales_Tax + 0.01*KCD + Delta_D*KCD ;
ADJ_C = C - CD - (C-CD).* Tax_Rate + 0.01*KCD + Delta_D*KCD ;
ADJ_G = G + X -M ; 
H = HRS_QTR .* ET_QTR ;
ADJ_X = CD + I - CD/C*Tax_Rate ; 
##
ypc = ADJ_Y./Pop_QTR;
hpc = H./Pop_QTR/1300;
xpc = ADJ_X./Pop_QTR;
gpc = ADJ_G./Pop_QTR;
cpc = ADJ_C./Pop_QTR;
iP = Pop_QTR ; 

K = Cap_Data.Capital ;
sp5 = Spline1D(1:size(K,1),K, k = 3 , bc = "extrapolate")
K_QTR =  sp5(1.25:0.25:size(ypc,1)/4+1);
# Captial Stock interpolated 
# 한국은행 데이터는 10억 단위 
kpc = K_QTR./iP * 10^9; # Per capita Capital Stock 
# end program
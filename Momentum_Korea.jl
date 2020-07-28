using DataFrames

using Query
using Queryverse
using Plots
using StatsFuns
using Distributions, Interpolations
using XLSX
cd("C:\\Users\\ksdskd\\Desktop\\Julia Replicate")
kospi = DataFrame(XLSX.readtable("kospi.xlsx","Sheet1" ,infer_eltypes = true)... )
d = stack(kospi, Not([:Symbol, :Item, :Symbol_Name ] ))

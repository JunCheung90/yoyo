require! Faker: '../../index'
require! ['should', 'async']

dataNum = 1000
mean = 0.0
std-dev = 1.0
precision = 0.2

arr = []

can = it # it在LiveScript中被作为缺省的参数，先置换为can

describe '测试正态分布', !->
  do
    before !->
      generate-normal-distribution-array!

  can '平均值大约为'+mean+'\n', !->
    cal-mean-value = cal-mean!
    cal-mean-value.should.be.within mean - precision, mean + precision
    console.log "计算的平均值为{#cal-mean-value}"

  can '标准差大约为'+std-dev+'\n', !->
    cal-std-dev-value = cal-std-dev!
    cal-std-dev-value.should.be.within std-dev - precision, std-dev + precision
    console.log "计算的标准差为{#cal-std-dev-value}"

  can '落在[u+-sigma]区间的概率约为0.68，落在[u+-2*sigma]区间的概率约为0.95\n', !-> 
    cal-mean-value = cal-mean!
    cal-std-dev-value = cal-std-dev!
    count1 = 0
    count2 = 0
    for i from 0 til dataNum
      if (cal-mean-value - cal-std-dev-value) < arr[i] < (cal-mean-value + cal-std-dev-value)
        count1++
      if (cal-mean-value - 2*cal-std-dev-value) < arr[i] < (cal-mean-value + 2*cal-std-dev-value)
        count2++ 
    prob1 = count1 / dataNum    
    prob2 = count2 / dataNum
    prob1.should.be.within 0.68 - precision, 0.68 + precision    
    prob2.should.be.within 0.95 - precision, 0.95 + precision  
    console.log "计算的[u+-sigma]区间的概率为{#prob1}，[u+-2*sigma]区间的概率为{#prob2}"  
      

generate-normal-distribution-array = !->
  for i from 0 til dataNum
    arr ++= Faker.random.normal_distribution mean, std-dev;

cal-mean = ->
  sum = 0
  for i from 0 til dataNum
    sum += arr[i]    
  sum / dataNum

cal-std-dev = ->
  cal-mean-value = cal-mean!
  power-sum = 0
  for i from 0 til dataNum
    power-sum += (arr[i] - cal-mean-value) ^ 2
  Math.sqrt (power-sum / dataNum)    
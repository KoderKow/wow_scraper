# scraping libraries
library(RSelenium)
library(rvest)
# XML, allows access to xpath selector
library(XML)
# string splice library
library(stringr)

## create a remoteDriver class object
rD <- rsDriver()

## extract client from rD
remDr <- rD[["client"]]

## Navigate to a page 
remDr$maxWindowSize()
remDr$navigate("http://www.wowhead.com/weapons")
## If the popup shows up, click it to get rid of it

popUp <- remDr$findElement(using ='css', value = '#item-gallery-listview > div.walkthrough-details-wrapper > div > div > div > div.walkthrough-details-text.right > div > a')
popUp$clickElement()

## ---- Loop ----
i <- 1 # for rows 1 - 50
j <- 1 # for data frame rows
f <- 1 # for filter seach count
rlvl90counter <- 0
filterHighValue <- ''
timeVec <- numeric()

# Total Weapons Amount
totalWeapons <- remDr$findElement(using = 'xpath', value = '//*[@id="tab-items"]/div[1]/div[2]')
totalWeapons <- totalWeapons$getElementAttribute('innerHTML')
totalWeapons <- as.numeric(str_split(totalWeapons, pattern = ' ')[[1]][1])

# test for filter automation
reqLvlLow <- remDr$findElement(using = 'css', value = '#filter-facet-min-req-level')
reqLvlLowText <- reqLvlLow$sendKeysToElement(list('1')) 
reqLvlHigh <- remDr$findElement(using = 'css', value = '#filter-facet-max-req-level')
reqLvlHighText <- reqLvlHigh$sendKeysToElement(list('25')) 

# apply filter button
applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
applyFilter$clickElement()

# filtered weapon count
filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
filterWeaponCount <- as.numeric(filterWeaponCount)

# sort table by name to avoid random order on back()s
sortByItem <- remDr$findElement(using = 'xpath', value = '//*[@id="tab-items"]/div[2]/table/thead/tr/th[2]/div/a/span')
sortByItem$clickElement()

initialStart <- Sys.time()

while(j <= 10000){
  
  startTime <- Sys.time()
  # sort back to original name order
  sortByItem <- remDr$findElement(using = 'xpath', value = '//*[@id="tab-items"]/div[2]/table/thead/tr/th[2]/div/a/span')
  sortLogic <- sortByItem$getElementAttribute('innerHTML')
  if(sortLogic != "<span>Name</span>"){
    sortByItem$clickElement()
    if(sortLogic != "<span>Name</span>"){
      sortByItem$clickElement()
    }
  }
  
  URLData <- remDr$getCurrentUrl()
  
  # find all weapons ----
  print(paste('select weapons table round', j, '..'))
  weapons <- remDr$findElements(using = "css", value = "#tab-items > div.listview-scroller > table > tbody > tr")
  
  # select weapon i from list
  print(paste('selecting weapon', i, '..'))
  selectWeapon <- weapons[[i]]$findChildElement(using = "css", value = "td:nth-child(3) > div > a")
  
  # required lvl
  print(paste('selecting weapon', i, 'required level...'))
  reqLvl <- remDr$findElement(using = 'xpath', value = paste("//*[@id=\"tab-items\"]/div[2]/table/tbody/tr[", i, "]/td[5]"))
  reqLvl <- reqLvl$getElementAttribute('innerHTML')
  reqLvl <- as.numeric(reqLvl)
  
  
  # click selected weapon
  print(paste('clicking weapon', i, '..'))
  selectWeapon$clickElement()
  
  # grab page's url for item # (not sure if this is used anymore..)
  print(paste('selecting URL', i, '..'))
  URL <- remDr$getCurrentUrl()
  
  # split string for item number
  print(paste('selecting item #', i, '..'))
  itemNum <- str_split(str_split(URL, pattern = '=')[[1]][2], pattern = '/')[[1]][1]
  
  # Weapon Data from div[x]/noscript. x changes between 2 or 3 based on ads----
  weaponData <- remDr$findElement(using = 'xpath', value = paste("//*[@id=\"main-contents\"]/div[2]/noscript", sep = ""))
  WeaponDataText <- weaponData$getElementAttribute('innerHTML')
  
  # Weapon Name ----
  print(paste('selecting weapon', i,'name...'))
  weaponName <- remDr$findElement(using = "xpath", value = paste("//*[@id='main-contents']/div[2]/h1", sep = ""))
  name <- weaponName$getElementAttribute('innerHTML')
  name <- str_split(name, '<span')[[1]][1]
  
  # Weapon Item Level ----
  # print(paste('selecting weapon', i,'item level...'))
  weaponItemLevel <- remDr$findElement(using = "xpath", value = paste("/html/head/meta[5]", sep = ""))
  itemLevel <- weaponItemLevel$getElementAttribute('content')
  itemLevel <- str_split(itemLevel,'item level of ')[[1]][2]
  itemLevel <- str_split(itemLevel,'. ')[[1]][1]
  
  # Upgrade ----
  weaponUpgrade <- str_split(WeaponDataText, 'Level &lt;!--uindex--&gt;')[[1]][2]
  weaponUpgrade <- str_trim(str_split(weaponUpgrade, '/')[[1]][2])
  upgradeLvl <- str_split(weaponUpgrade, '&lt;')[[1]][1]
  
  # Weapon Bind on Pick Up ----
  # print(paste('selecting weapon', i, 'bind setting...'))
  bind <- str_split(WeaponDataText, '!--bo--&gt;')
  bind <- str_split(bind[[1]][2], '&lt;')[[1]][1]
  
  # Weapon Hand Characteristic ----
  # print(paste('selecting weapon', i,'hand value...'))
  hand <- str_split(WeaponDataText, 'width=\"100%\"&gt;&lt;tr&gt;&lt;td&gt;')[[1]][2]
  hand <- str_split(hand, '&lt;')[[1]][1]

  # Weapon Type ----
  # print(paste('selecting weapon', i,'type...'))
  type <- str_split(WeaponDataText, 'class=\"q1\"&gt;')[[1]][2]
  type <- str_split(type, '&lt;')[[1]][1]
  
  # Weapon Damage Range (High + Low) ----
  # print(paste('selecting weapon', i, 'damage range...'))
  damageRange <- str_split(WeaponDataText, '!--dmg--&gt;')[[1]][2]
  damageRange <- str_split(damageRange, ' ')
  # Weapon Low Damage
  damageLow <- as.numeric(gsub(',', '', damageRange[[1]][1]))
  # Weapon High Damage
  damageHigh <- as.numeric(gsub(',', '', damageRange[[1]][3]))
  
  # Weapon Speed ----
  # print(paste('selecting weapon', i, 'speed...'))
  speed <- str_split(WeaponDataText, '!--spd--&gt;')[[1]][2]
  speed <- as.numeric(gsub(',', '', str_split(speed, '&lt;')[[1]][1]))
  
  # Weapon DPS ----
  # print(paste('selecting weapon', i, 'dps...'))
  dps <- str_split(WeaponDataText,'!--dps--&gt;\\(')
  dps <- as.numeric(gsub(',', '', str_trim(str_split(dps[[1]][2], 'damage')[[1]][1])))
  
  # Weapon Or Option ----
  # print(paste('selecting weapon', i, 'Or Option...'))
  or <- str_split(WeaponDataText,'damage per second\\)&lt;br /&gt;&lt;span&gt;&lt;')
  or <- str_split(dps[[1]][2], '&lt;')[[1]][1]
  if(!is.na(str_detect(or, 'or'))){
    orOption <- 1
  }else{
    orOption <- NA
  }
  
  # Agility Test ----
  # print(paste('selecting weapon', i,'Agility level...'))
  weaponAgility <- str_split(WeaponDataText, '!--stat3--&gt;\\+')[[1]][2]
  agility <- as.numeric(gsub(',', '', str_trim(str_split(weaponAgility, 'Agility')[[1]][1])))
  
  # Intellect Test ----
  # print(paste('selecting weapon', i,'Intellect level...'))
  weaponIntellect <- str_split(WeaponDataText, '!--stat5--&gt;\\+')[[1]][2]
  intellect <- as.numeric(gsub(',', '', str_trim(str_split(weaponIntellect, 'Intellect')[[1]][1])))
  
  # Mastery Test ----
  # print(paste('selecting weapon', i,'Mastery level...'))
  weaponMastery <- str_split(WeaponDataText, '!--rtg49--&gt;')[[1]][2]
  mastery <- as.numeric(gsub(',', '', str_trim(str_split(weaponMastery, 'Mastery')[[1]][1])))
  
  # Stamina Test ----
  # print(paste('selecting weapon', i,'Stanima level...'))
  weaponStamina <- str_split(WeaponDataText, '!--stat7--&gt;\\+')[[1]][2]
  stamina <- as.numeric(gsub(',', '', str_trim(str_split(weaponStamina, 'Stamina')[[1]][1])))
  
  
  # Strength Test ----
  # print(paste('selecting weapon', i,'Stanima level...'))
  weaponStrength <- str_split(WeaponDataText, '!--stat4--&gt;\\+')[[1]][2]
  strength <- as.numeric(gsub(',', '', str_trim(str_split(weaponStrength, 'Strength')[[1]][1])))
  
  # Critical Strike Test ----
  # print(paste('selecting weapon', i,'Critical Strike level...'))
  weaponCritStrike <- str_split(WeaponDataText, '!--rtg32--&gt;')[[1]][2]
  critStrike <- as.numeric(gsub(',', '', str_trim(str_split(weaponCritStrike, 'Critical')[[1]][1])))
  
  # Durability Test ----
  # print(paste('selecting weapon', i,'Durability level...'))
  weaponDurability <- str_split(WeaponDataText, 'Durability ')[[1]][2]
  durability <- as.numeric(gsub(',', '', str_split(weaponDurability, ' ')[[1]][1]))
  
  # Haste ----
  # print(paste('selecting weapon', i,'Haste level...'))
  weaponHaste <- str_split(WeaponDataText, '!--rtg36--&gt;')[[1]][2]
  haste <- as.numeric(gsub(',', '', str_trim(str_split(weaponHaste, 'Haste')[[1]][1])))
  
  # Versatility ----
  # print(paste('selecting weapon', i,'Versatility level...'))
  weaponVersatility <- str_split(WeaponDataText, '!--rtg40--&gt;')[[1]][2]
  versatility <- as.numeric(gsub(',', '', str_trim(str_split(weaponVersatility, 'Versatility')[[1]][1])))
  
  # Classes ---- took out, unsure of best method
  # print(paste('selecting weapon', i,'Class level...'))
  # weaponClasses <- str_split(WeaponDataText, 'class=\"c7\"&gt;')[[1]][2]
  # classes <- str_split(weaponClasses, '&lt;')[[1]][1]
  
  # Weapon Sell Price ----
  # print(paste('selecting weapon', i, 'sell price...'))
  sellPriceGold <- str_split(WeaponDataText, 'class=\"moneygold\"&gt;')
  sellPriceGold <- as.numeric(gsub(',', '', str_split(sellPriceGold[[1]][2], '&lt;')[[1]][1]))
  # Silver
  sellPriceSilver <- str_split(WeaponDataText, 'class=\"moneysilver\"&gt;')
  sellPriceSilver <- as.numeric(gsub(',', '', str_split(sellPriceSilver[[1]][2], '&lt;')[[1]][1]))
  # Copper
  sellPriceCopper <- str_split(WeaponDataText, 'class=\"moneycopper\"&gt;')
  sellPriceCopper <- as.numeric(gsub(',', '', str_split(sellPriceCopper[[1]][2], '&lt;')[[1]][1]))
  
  # Weapon Patch / Expansion ----
  weaponPatch <- remDr$findElement(using = 'xpath', value = paste("/html/head/meta[6]", sep = ""))
  patch <- weaponPatch$getElementAttribute('content')
  patch <- str_split(patch, 'Item, ')[[1]][2]
  patch <- str_split(patch, ', ')
  patchNum <- patch[[1]][1]
  if(patch[[1]][2] == "Alliance" | patch[[1]][2] == "Horde"){
    side <- patch[[1]][2]
    expansion <- patch[[1]][3]
  }else{
    expansion <- patch[[1]][2]
    side <- NA
  }
  
  # Create Date Frame ----
  print(paste('Creating data frame row', j))
  if(!exists('wowWeapons')){
    wowWeapons <- data.frame(name, itemLevel, upgradeLvl, bind, hand, type, damageLow, damageHigh, speed, dps, orOption, agility, critStrike, haste, intellect, mastery, stamina, strength, versatility, durability, reqLvl, sellPriceGold, sellPriceSilver, sellPriceCopper, side, expansion, patchNum)
    colnames(wowWeapons)[1] <- 'name'
    colnames(wowWeapons)[5] <- 'hand'
    colnames(wowWeapons)[6] <- 'type'
    
  }else{
    newRow <- data.frame(name, itemLevel, upgradeLvl, bind, hand, type, damageLow, damageHigh, speed, dps, orOption, agility, critStrike, haste, intellect, mastery, stamina, strength, versatility, durability, reqLvl, sellPriceGold, sellPriceSilver, sellPriceCopper, side, expansion, patchNum)
    names(newRow) <- names(wowWeapons)
    wowWeapons <- rbind(wowWeapons, newRow)
  }
  
  print(paste('Weapon', j, 'complete! Going Back..'))
  timeVec[j] <- endTime - startTime
  remDr$goBack()

  # logic for going to next page
  if(i == 50){
    print('Going to the next page')
    nextPage <- remDr$findElement(using ='css', value = '#tab-items > div.listview-band-top > div.listview-nav > a:nth-child(4)')
    nextPage$clickElement()
    i <- 0
  }
  
  # filter automation start (up to rlvl 89) ----
  if(f == filterWeaponCount){
    print('f == filterWeaponCount')
    filterHighValue <- remDr$findElement(using = 'xpath', value = '//*[@id="filter-facet-max-req-level"]')
    filterHighValue <- filterHighValue$getElementAttribute('value')
    
    # 26-55
    if(filterHighValue == '25'){
      print('f == filterWeaponCount')
      
      # test for filter automation
      reqLvlLow <- remDr$findElement(using = 'css', value = '#filter-facet-min-req-level')
      reqLvlLow$clearElement()
      reqLvlLowText <- reqLvlLow$sendKeysToElement(list('26')) 
      reqLvlHigh <- remDr$findElement(using = 'css', value = '#filter-facet-max-req-level')
      reqLvlHigh$clearElement()
      reqLvlHighText <- reqLvlHigh$sendKeysToElement(list('55')) 
      
      # apply filter button
      applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
      applyFilter$clickElement()
      sortByItem$clickElement()
      # filtered weapon count
      filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
      filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
      filterWeaponCount <- as.numeric(filterWeaponCount)
      f <- 0
      i <- 0
      
      #56-65
    }else if(filterHighValue == '55'){
      reqLvlLow <- remDr$findElement(using = 'css', value = '#filter-facet-min-req-level')
      reqLvlLow$clearElement()
      reqLvlLowText <- reqLvlLow$sendKeysToElement(list('56')) 
      reqLvlHigh <- remDr$findElement(using = 'css', value = '#filter-facet-max-req-level')
      reqLvlHigh$clearElement()
      reqLvlHighText <- reqLvlHigh$sendKeysToElement(list('65')) 
      
      # apply filter button
      applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
      applyFilter$clickElement()
      sortByItem$clickElement()
      # filtered weapon count
      filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
      filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
      filterWeaponCount <- as.numeric(filterWeaponCount)
      f <- 0
      i <- 0
      
      # 66 - 70
    }else if(filterHighValue == '65'){
      reqLvlLow <- remDr$findElement(using = 'css', value = '#filter-facet-min-req-level')
      reqLvlLow$clearElement()
      reqLvlLowText <- reqLvlLow$sendKeysToElement(list('66')) 
      reqLvlHigh <- remDr$findElement(using = 'css', value = '#filter-facet-max-req-level')
      reqLvlHigh$clearElement()
      reqLvlHighText <- reqLvlHigh$sendKeysToElement(list('70')) 
      
      # apply filter button
      applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
      applyFilter$clickElement()
      sortByItem$clickElement()
      # filtered weapon count
      filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
      filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
      filterWeaponCount <- as.numeric(filterWeaponCount)
      f <- 0
      i <- 0
      
      # 71-79
    }else if(filterHighValue == '70'){
      reqLvlLow <- remDr$findElement(using = 'css', value = '#filter-facet-min-req-level')
      reqLvlLow$clearElement()
      reqLvlLowText <- reqLvlLow$sendKeysToElement(list('71')) 
      reqLvlHigh <- remDr$findElement(using = 'css', value = '#filter-facet-max-req-level')
      reqLvlHigh$clearElement()
      reqLvlHighText <- reqLvlHigh$sendKeysToElement(list('79')) 
      
      # apply filter button
      applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
      applyFilter$clickElement()
      sortByItem$clickElement()
      # filtered weapon count
      filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
      filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
      filterWeaponCount <- as.numeric(filterWeaponCount)
      f <- 0
      i <- 0
      
      # 80-80
    }else if(filterHighValue == '79'){
      reqLvlLow <- remDr$findElement(using = 'css', value = '#filter-facet-min-req-level')
      reqLvlLow$clearElement()
      reqLvlLowText <- reqLvlLow$sendKeysToElement(list('80')) 
      reqLvlHigh <- remDr$findElement(using = 'css', value = '#filter-facet-max-req-level')
      reqLvlHigh$clearElement()
      reqLvlHighText <- reqLvlHigh$sendKeysToElement(list('80')) 
      
      # apply filter button
      applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
      applyFilter$clickElement()
      sortByItem$clickElement()
      # filtered weapon count
      filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
      filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
      filterWeaponCount <- as.numeric(filterWeaponCount)
      f <- 0
      i <- 0
      
      #81-85
    }else if(filterHighValue == '80'){
      reqLvlLow <- remDr$findElement(using = 'css', value = '#filter-facet-min-req-level')
      reqLvlLow$clearElement()
      reqLvlLowText <- reqLvlLow$sendKeysToElement(list('81')) 
      reqLvlHigh <- remDr$findElement(using = 'css', value = '#filter-facet-max-req-level')
      reqLvlHigh$clearElement()
      reqLvlHighText <- reqLvlHigh$sendKeysToElement(list('85')) 
      
      # apply filter button
      applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
      applyFilter$clickElement()
      sortByItem$clickElement()
      # filtered weapon count
      filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
      filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
      filterWeaponCount <- as.numeric(filterWeaponCount)
      f <- 0
      i <- 0
      
      #86-90
    }else if(filterHighValue == '85'){
      reqLvlLow <- remDr$findElement(using = 'css', value = '#filter-facet-min-req-level')
      reqLvlLow$clearElement()
      reqLvlLowText <- reqLvlLow$sendKeysToElement(list('86')) 
      reqLvlHigh <- remDr$findElement(using = 'css', value = '#filter-facet-max-req-level')
      reqLvlHigh$clearElement()
      reqLvlHighText <- reqLvlHigh$sendKeysToElement(list('89')) 
      
      # apply filter button
      applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
      applyFilter$clickElement()
      sortByItem$clickElement()
      # filtered weapon count
      filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
      filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
      filterWeaponCount <- as.numeric(filterWeaponCount)
      f <- 0
      i <- 0
      
      # 91-99
    }else if(filterHighValue == '89'){
      reqLvlLow <- remDr$findElement(using = 'css', value = '#filter-facet-min-req-level')
      reqLvlLow$clearElement()
      reqLvlLowText <- reqLvlLow$sendKeysToElement(list('90')) 
      reqLvlHigh <- remDr$findElement(using = 'css', value = '#filter-facet-max-req-level')
      reqLvlHigh$clearElement()
      reqLvlHighText <- reqLvlHigh$sendKeysToElement(list('90'))
      
      # rlvl 90 filter 1
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(1)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(2)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(3)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(4)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(5)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(6)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(7)')
      f90$clickElement()
      
      # apply filter button
      applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
      applyFilter$clickElement()
      sortByItem$clickElement()
      # filtered weapon count
      filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
      filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
      filterWeaponCount <- as.numeric(filterWeaponCount)
      f <- 0
      i <- 0
      
      rlvl90filter1 <- remDr$findElement(using = 'xpath', value = '//*[@id="tab-items"]/div[1]/div[1]/span/b[3]')
      rlvl90filter1 <- rlvl90filter1$getElementAttribute('innerHTML')
      rlvl90filter1 <- as.numeric(rlvl90filter1)
      
      filterHighValue <- remDr$findElement(using = 'xpath', value = '//*[@id="filter-facet-max-req-level"]')
      filterHighValue <- filterHighValue$getElementAttribute('value')
      
      
    }
    
    else if(rlvl90counter == rlvl90filter1){
      # clear filter 1 button
      clearfilterlist <- remDr$findElement(using = 'css', value = '#filter-facet-type-clear-link')
      clearfilterlist$clickElement()
      
      # rlvl 90 filter 2
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(8)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(9)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(10)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(11)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(12)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(13)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(14)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(15)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(16)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(17)')
      f90$clickElement()
      f90 <- remDr$findElement(using = 'css', value = '#filter-facet-type > option:nth-child(18)')
      f90$clickElement()
      
      # apply filter button
      applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
      applyFilter$clickElement()
      sortByItem$clickElement()
      # filtered weapon count
      filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
      filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
      filterWeaponCount <- as.numeric(filterWeaponCount)
      f <- 0
      i <- 0
      
      # 100
    }else if(filterHighValue == '90'){
      clearfilterlist <- remDr$findElement(using = 'css', value = '#filter-facet-type-clear-link')
      clearfilterlist$clickElement()
      reqLvlLow <- remDr$findElement(using = 'css', value = '#filter-facet-min-req-level')
      reqLvlLow$clearElement()
      reqLvlLowText <- reqLvlLow$sendKeysToElement(list('91')) 
      reqLvlHigh <- remDr$findElement(using = 'css', value = '#filter-facet-max-req-level')
      reqLvlHigh$clearElement()
      reqLvlHighText <- reqLvlHigh$sendKeysToElement(list('99')) 
      
      # apply filter button
      applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
      applyFilter$clickElement()
      sortByItem$clickElement()
      # filtered weapon count
      filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
      filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
      filterWeaponCount <- as.numeric(filterWeaponCount)
      f <- 0
      i <- 0
      
      # 100
    }
    
    else if(filterHighValue == '99'){
      reqLvlLow <- remDr$findElement(using = 'css', value = '#filter-facet-min-req-level')
      reqLvlLow$clearElement()
      reqLvlLowText <- reqLvlLow$sendKeysToElement(list('100')) 
      reqLvlHigh <- remDr$findElement(using = 'css', value = '#filter-facet-max-req-level')
      reqLvlHigh$clearElement()
      reqLvlHighText <- reqLvlHigh$sendKeysToElement(list('100')) 
      
      # apply filter button
      applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
      applyFilter$clickElement()
      sortByItem$clickElement()
      # filtered weapon count
      filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
      filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
      filterWeaponCount <- as.numeric(filterWeaponCount)
      f <- 0
      i <- 0
      
      # 101-110
    }else if(filterHighValue == '100'){
      reqLvlLow <- remDr$findElement(using = 'css', value = '#filter-facet-min-req-level')
      reqLvlLow$clearElement()
      reqLvlLowText <- reqLvlLow$sendKeysToElement(list('101')) 
      reqLvlHigh <- remDr$findElement(using = 'css', value = '#filter-facet-max-req-level')
      reqLvlHigh$clearElement()
      reqLvlHighText <- reqLvlHigh$sendKeysToElement(list('110')) 
      
      # apply filter button
      applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
      applyFilter$clickElement()
      sortByItem$clickElement()
      # filtered weapon count
      filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
      filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
      filterWeaponCount <- as.numeric(filterWeaponCount)
      f <- 0
      i <- 0
      
    }else if(filterHighValue == '110'){
      reqLvlLow <- remDr$findElement(using = 'css', value = '#filter-facet-min-req-level')
      reqLvlLow$clearElement()
      reqLvlLowText <- reqLvlLow$sendKeysToElement(list('0')) 
      reqLvlHigh <- remDr$findElement(using = 'css', value = '#filter-facet-max-req-level')
      reqLvlHigh$clearElement()
      reqLvlHighText <- reqLvlHigh$sendKeysToElement(list('0')) 
      
      # apply filter button
      applyFilter <- remDr$findElement(using = 'css', value = '#fi > form > div.filter-row > button')
      applyFilter$clickElement()
      sortByItem$clickElement()
      # filtered weapon count
      filterWeaponCount <- remDr$findElement(using = 'css', value = '#tab-items > div.listview-band-top > div.listview-nav > span > b:nth-child(3)')
      filterWeaponCount <- filterWeaponCount$getElementAttribute('innerHTML')
      filterWeaponCount <- as.numeric(filterWeaponCount)
      f <- 0
      i <- 0
      
    }else if(filterHighValue == '0'){
      print('testing breaks')
      break
    }
  }
  # end filter logic 
  
  i <- i + 1
  j <- j + 1
  f <- f + 1
  if(filterHighValue == '90'){
    rlvl90counter <- rlvl90counter + 1
  }
  
}
finalTime <- Sys.time()
# Loop Finish ----
# read.table("file.txt", dec=",")
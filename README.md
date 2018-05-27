# Web Scraper - World of Warcraft

The main goal of this project was to learn how to use the R libraries rvest and RSelenium. The web scraping would be taking place on the website wowhead.com. There is about 10,000 rows of data to collect.

## Learning Points
-	Navigate the DOM to capture desired element values
-	Used R’s _RSelenium_ and _rvest_ library to capture data
-	Construct a R script to automate the complete web scraping process
-	Made a data frame with captured data to save to a csv file for data analysis

## Web Scraping Process
The web scraper goes to the wowhead.com weapon page. There is about 10,000 weapons worth of data. All of the data we want to collect from these weapons are not presented in the rows of the table. For each page, there are 50 weapons.

#### Example of table view of weapons
<img src="https://github.com/KoderKow/wow_scraper/blob/master/readme_images/table_view.png" width="70%" height="70%">

In order to capture all of the data we want we will need to click on each row, collect the data, go back to the previous page, and then click on the next item.

#### Example of weapon view for all attributes
<img src="https://github.com/KoderKow/wow_scraper/blob/master/readme_images/item_displayed_vs_total.png" width="50%" height="50%">

At the start I was collecting the data directly from the elements shown on the top left box of the page. Issues started coming up when a weapon had a different amount of attributes. For example, if a weapon had two attributes such as strength and agility, that takes up 2 spaces on the DOM. Then if the next weapon had only one attribute, the script would return an error. After exploring the DOM I was able to find all of the data in a \<noscript\> tag. All of the attributes had different code tags (ie;'!--stat3--&gt;\\+' = agility). After sorting out all of the tags I was able to use string manipulation to return the information desired.
  
First time running the script all the way through with no errors showed the next hurdle to jump. The original default weapon data only showed about 1,000 of the 10,000 total weapons. The next step was to automate a filtering process to collect all the weapons.

#### By default, the page displays around 1000 max
<img src="/img/wow-scraper/item_displayed_vs_total.png" width="80%" height="80%">

I decided to search for weapons based on their item level. For example, levels 1-25, 26-35, etc. This would return all the weapons in chunks. Once the first chunk of weapons was collected the script clears the filter and inputs the next number range.

After thinking this project was complete I showed the data to my professor. We found out the weapon attributes were not correct. My string manipulation was not collecting stats correctly that had a comma in it (ex: 1,247). This was a simple fix, but then I noticed something completely different on the website. When you click a weapon and then go back, the order the weapons on the table were not static. The order changed! Eventually I found a solution, constantly sort the table by the weapon name everytime the script goes back to the main page.

Unfortunately during this time, World of Warcraft introduced weapon scalability to their weapons. To put it simply and in terms I understand, a large amount of weapons in their game now 'upgrade' as you level up. For example, I am level one and have a level one sword that does 1-2 damage and has +1 strength. When I level up to level two the sword now does 2-3 damage and has +2 strength. World of Warcraft has 120 levels. This now means a lot of the weapons have different stats on 120 levels. This really put a thud on this web scraper.

After talking to my professor, if I chose to continue with this project and wanted to do data analysis on the data, I could make an assumption that all weapons would be looked at in a maxed level view (player level = 120). Sadly, however, this will require going back and changing how a lot of the data is collected.

## Reflection
It is unfortunate to get hit by that update, but the process of collecting the data and fixing all the issues that came up was an amazing learning experience. There is still possibility of data analysis with the old data I collected that had the comma issue.

## Data
The data (.csv file) is on my [github](https://github.com/KoderKow/wow_scraper). I wanted to share what the data looked like and that I had success in gathering a lot of different attributes for every weapon.

## Acknowledgments
I want to thank Professor Lourens for sharing his idea for this project. Professor Lourens assisted me on learning web scraping through rvest/RSelenium and addressed errors I came across.

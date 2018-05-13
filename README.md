# Web Scraper - World of Warcraft

The main goal of this project was to learn how to use the R libraries rvest and RSelenium. The web scraping would be taking place on the website wowhead.com, there would be about 10,000 rows of data to collect. \

## Learning Points
- Navigate the DOM to capture element values
- Used rvest and RSelenium to capture data
- Construct script to to automate the complete process
- Construct dataframe with captured data
- Save data to a csv file for future use

## Web Scraping Process
The web scraper goes to wowhead.com weapon page. There is about 10,000 weapons worth of data. All of the information for these weapons are not presented in the rows of the table. For each page, there are 50 weapons. In order to capture all of the data we want we will need to click on each row, collect the data, go back to the previous page, then click on the next item.

At the start I was collecting the data directly from the elements shown on the page. Issues come up when a weapon has a different amount of attributes. For example, if a weapon has two attributes such as strength and agility, that takes up 3 spaces on the DOM. Then if the next weapon has only one, the script would return an error. After exploring the DOM I was able to find all of the data in a <noscript> tag. All of the attributes have different code tags. Sorting out all of the tags I was able to use string manipulation to return the information desired.
  
![alt](https://github.com/KoderKow/wow_scraper/blob/master/readme_images/table_view.png)
  
First time running the script all the way through with no error showed the next hurdle. The original default weapon data only showed about 1,000 of the 10,000 total weapons. The next step was to automate a filtering process. I decided to search for weapons based on their item level. For example, levels 1-25, 26-35, etc. This would return all the weapons in chunks. Once the first chunk of weapons was collected the script clears the filter and inputs the next number range.

After thinking this project was complete I showed the data to my professor. We find out the weapon attributes were not correct. My string manipulation was not collecting stats correctly that had a comma in it (ex: 1,247). This was a simple fix, but then I noticed something completely different on the website. When you click a weapon and then go back, the order the weapons on the table were not static. The order changed! Eventually I found a solution, constantly sort the table by the weapon name everytime the script goes back to the main page.

Unfortunately during this time, World of Warcraft introduced weapon scalability to their weapons. To put it simply and in terms I understand, a large amount of weapons in their game now 'upgrade' as you level up. For example, I am level one and have a level one sword that does 1-2 damage and has +1 strength. When I level up to level two the sword now does 2-3 damage and has +2 strength. World of Warcraft has 120 levels. This now means a lot of the weapons have different stats on 120 levels. This really put a thud on this web scraper.

After talking to my professor, if I chose to continue with this project and wanted to do data analysis on the data, I could make an assumption that all weapons would be looked at in a maxed level view (player level = 120). Sadly, however, this will require going back and changing how a lot of the data is collected.

## Reflection
It is unfortunate to get hit by that update, but the process of collecting the data and fixing all the issues that came up was an amazing learning experience.

## Data
The data in files is from before addressing the weapon attribute problem (comma issue). I wanted to share what the data looked like and that I had success in gathering a lot of different attributes for every weapon.

## Acknowledgments
Professor Lourens for sharing his idea on collecting this idea and assisting me on learning web scraping through rvest/RSelenium and addressing errors I came across.

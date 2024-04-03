# March Madness Forecast

I've provided some code for web scraping + analysis of teams preforming in the men's and women's NCAA tournaments. The purpose is to provide a unified score for each team. Each team's score combines measures of player productivity and a measure of strength of schedule which I describe in greater depth below.

The purpose of this exercise is solely to complete the most accurate bracket. This is not a probabilistic forecast. No standard errors. No confidence intervals. Only standardized means.

<img src="edna.png" width=50% height=50%></a>

## Minutes Played

Sometimes productive players get hurt. Sometimes players aren't on the court as much time as their productivity would suggest they should. Sometimes, bench players get wildly distorted productivity stats because they only play during times when teams have given up trying to win. Thus, I create a variable which estimates the amount of time they will play (based on how much they've played in the past).

$$SMP_{pt} = \dfrac{MP_{pt}}{G_t}$$

The equation above represents the share of minutes (*SMP*) player *p* on team *t* has played this year given the number of games (*G*) they participated in. *MP* is the total amount of minutes the player has played so far that season.

$$W_t = \dfrac{\sum_t \big(SMP_{pt} \big) \times 5}{40}$$

However, because players will inevitably miss some time due to injury, the sum of the share of minutes played will very likely overstate the overall number of minutes which are possible to play within a game.Thus, I create a weighting variable (*W*) for each team *t* to help better estimate actual playing time. To do so, I aggregate each team's share of minutes played (*SMP*) and multiply by the maximum number of players which can be on the court at a time (5). I then divide this by the total minutes that can be played per player (40). The closer this number is to 1, the less adjustments to playing time the team has made throughout the season.

$$EMP_{pt} = \dfrac{SMP_{pt}}{W_t}$$

Finally, estimated playing time (*EMP*) is calculated by dividing the share of minutes (*SMP*) for each player *p* on team *t* by a team playing time weight (*W*).

## Productivity

I borrow three measures of players' productivity from the season in which the tournament is being held: player efficiency rating (PER), win share per 40 minutes (WS/48) and box plus minus (BPM). The description of each variable can be found [here](https://www.basketball-reference.com/about/glossary.html).

$$V_{pt} = S_{pt} \times EMP_{pt}$$

I calculate the playing-time adjusted productivity value (*V*) for each player *p* on team *t* by multiplying productivity statistic *S* with their estimated minutes played (*EMP*).

$$Z_{pt} = \dfrac{V_{pt} - m(V_{pt})}{sd(V_{pt})}$$

I standardize (*Z*) this variable to account for the fact that each productivity statistic *S* has a different mean value. Thus, each player is assigned a score which represents the degree to which their productivity differs from the mean in standard deviations.

$$\mu_{pt} = \dfrac{\sum_{pt} Z_{spt}}{\ell(S)}$$

I take the sum of each of the different standardized productivity statistics (*s*) for each player *p* on team *t*. Dividing by the unique number of productivity statistics ($\ell(S)$) provides an average productivity score for each player. For example, Caitlin Clark had the highest average score (4.5) for either men or women in the 2023-2024 season.

$$G_t = \sum_{t} \mu_{pt}$$

Teams receive a value of how good they are (*G*) by taking the sum of the playing-time adjusted, standardized productivity measure ($\mu$) for each player *p* on team *t*.

## Strength of Schedule

Sometimes really good players can look average due to the frequency with which they play even more talented players. I do my best to adjust for this. To do so, I take the strength of schedule variable (SOS) for each team. See [here](https://web.archive.org/web/20180531115621/https://www.pro-football-reference.com/blog/index4837.html?p=37) for a discription of how it is calculated. I standardize this measure for all teams such that it is measured in terms of standard deviations above the mean. Importantly higher values correspond to higher average quality of opponents. Alabama's men's team had the highest strength of schedule for the 2023-2024 season having played in the 4th most difficult conference and faced out-of-conference opponents of Morehead State, Indiana State, Ohio State, Oregon, Clemson, Purdue, Creighton, and Arizona.


## Overall Measure

$$Q_t = G_t + SOS_t$$

The overall measure of a team's quality (*Q*) simply adds how good they are (*G*) with their strength of schedule (*SOS*). In the future, I will find a way to weight these. For now, they receive equal weighting.

# Quality of Predictions

I will periodically update the quality of my predictions. As of April 3, 2024 my women's bracket is doing quite well (84th pecentile) while my once excellent men's bracket has since collapsed into flames (50th percentile) in the Sweet 16 with the loss of my predicted champion: the University of Houston.

|              |       Men      |   |      Women     |
|:------------:|:--------------:|:-:|:--------------:|
|  Round of 64 | 22 of 32 (69%) |   | 28 of 32 (88%) |
|  Round of 32 | 12 of 16 (75%) |   | 13 of 16 (81%) |
|   Sweet 16   |  1 of 8 (13%)  |   |  4 of 8 (50%)  |
|    Elite 8   |  1 of 4 (25%)  |   |  3 of 4 (75%)  |
|  Final Four  |                |   |                |
| Championship |                |   |                |
|   Champion   |                |   |                |

Historically the women's bracket has always been easier to predict, but this is by far the worst my men's bracket has preformed. Looks like I will have to revisit the chalk board this time next year.

# instagram-mining

This repository includes code that I used for my Master Thesis: "Mining Location-Based Social Networks: a Bayesian approach to Instagram’s API data".

## Introduction
The purpose of the thesis is to showing how a Location-Based Social Network (LBSN), such as Instagram, can be used to detect individuals’ presence and movements within the city of Milan. Instagram offers user
generated data about the presence of people in an area, since it provides the geographical
localisation of the picture; and about the way individuals experience a place, thanks to
hashtags. The thesis shows how the data can be used to study movement patterns inside a city, through data visualisation
techniques and spatio-temporal models. On the methodological side, this is the first work (as far as I know!) that uses the Integrated Nested
Laplace Approximation method developed by [Rue, Martino, and Chopin (2009)](https://rss.onlinelibrary.wiley.com/doi/10.1111/j.1467-9868.2008.00700.x) to analyse
social media data. The approach was chosen given that some of its features fits well
into the analytical framework of social media data. First, it is highly flexible in the
modelization phase of the analysis, thus allowing the researcher to tune the analysis
according to the characteristics of the data retrieved. For example, it allows to use
different likelihood assumptions on the spatial point process and to easily add covariates
to the analysis. Furthermore, spatial and temporal dimensions can be fully exploited even
through the use of interactions. Diagnostic and model selection tools are also available,
so that the researcher can be guided in the process of adjusting the model. In addition,
the method provides the possibility of performing forecasting activities, thus allowing to
understand the predictive power of the chosen models.
Finally, along the quantitative approach, a more qualitative approach is also explored,
by the collection and geographical visualization of the hashtags of the users.

# Data Inspection

## Temporal Dimension
For my thesis, I extracted and analysed hundreds of thousands of pictures taken in the city of Milan by Instagram users over the course of 5 years.
The data shows power-law-like distributions, as [expected from Social Network data](https://www.cs.cornell.edu/home/kleinber/networks-book/networks-book-ch18.pdf). One example is the number of pictures per user.

![Frequency of number of pictures per user](/images/distribution.png)

Another typical pattern is the day/night pattern. The two figures below display this intra-day seasonality. One shows two peaks inside a day, one around 13:00 and the other around 18:00, while the polar coordinate graph highlights the difference between the activity during working hours (in dark blue) and free time (in light blue).

![Intra day trend, split by year](/images/hourpattern.png)
![Polar Coordinates representation of daily activity](/images/workhours.png)

## Spatial Dimension

As expected, pictures were mostly clustered in points of interest in the city (city center and the EXPO area).

![Spatial Distribution](/images/spatialdistribution.png)

## Spatio-Temporal Information
Similar patterns can be observed when one plots the data using also both spatial and geographical information. Combining the two brings new insights and expected findings.
So, for example, the figure below shows the increasing usage of Instagram from 2010 to 2015,
but it also displays two other phenomena. First, while until 2013 the media was used
mostly to take pictures in the innermost part of the city, now pictures are being taken on
the whole territory. Second, the event of the Universal Exposition (Expo) was captured
by the LBSN data. Activity in that area (top left corner of the map) increased suddenly
in 2015.

![Spatio-temporal growth of Instagram](/images/mapsyearspoints.png)

A split of the year 2015 by month identifies the time range of the EXPO event, which
18 opened in May and closed in October.

![2015 data split by month](/images/mapsmonthspoints.png)

## Hashtags

The collected hashtags can provide context to these maps. The figure below is an hashtag map representing data from September
2015. During that period, Milan hosted the annual Milan Fashion Week, and the event is mirrored in the words of Instagram Users. “Bloggerlife”, “fashion”, “mfw2015” (an
acronym for “Milan Fashion Week”) are gravitating around the tag of a fashion brand,
Pinko, which most likely created a customer experience which highly involved the use
of Instagram. In the same month, by contrast, the tag “exam” looms over the Catholic
University of the Sacred Heart.

![Hashtag Map of September 2015](/images/september2015.png)

# Modeling

## Prepare the Data
While Instagram provided the spatio-temporal data, the Italian National Institute of
Statistics (ISTAT) provided the data to define the neighbourhood structure.
Geostatistical data are the representation of a continuous spatial process, but in order
to use them in the INLA approach, the process should be transformed into a discrete and
indexed spatio-temporal process. This transformation can be done by fitting data into pre-existing administrative boundaries. In the case of Milan, ISTAT provides
several types of urban administrative boundaries, such as NILs (local identity nucleus).
Census sections data were created in 2011 and are available in different formats, such
as shapefile (.shp). This format is the one needed by INLA to create neighborhood
matrices, which are used in the regression models. The geographical projection used is
Gauss-Boaga, which is based on an Italian datum, the Monte Mario, a hill near Rome. A
datum is a set of reference points used as a frame of reference to translate positions taken
from a map to position on the surface of the Earth and vice versa. Given that Instagram
uses a different type of projection, the same was applied to Milan’s map.
Census Sections divide Milan into 6079 sectors, with an average area of 29,901 square meters
(0.029901 square kilometres), which represents about 0.016% of the city area.
Each Instagram picture retrieved was categorised into areas defined by this type of
administrative boundaries. An example of the overlay can be seen in the below figure.

![Example of the aggregation process](/images/overlay_example.png)

Aggregating geographical data in a shapefile also allows the researcher to easily spot
clusters of behaviour. For example, looking at the central area of Milan and splitting the
data on a hourly basis, one can see some interesting patterns, as Figure 4.3 displays. In
the first hours of the day, Parco Sempione (in the upper left corner) shows some activity,
most likely linked to the presence of two night clubs in the area. As soon as the day
begins, the Duomo and the Catholic University of the Sacred Heart areas light up. While
the latter fades towards the evening, the former grows stronger. Around 18:00, the Brera
area suddenly sees an increase in the number of people present, probably attracted by
restaurants offering aperitifs.

![Users’ presence in different hours of the day in the central area of Milan](/images/duomohours2015.png)

## Model

Several different models were specified, to test different likelihood assumptions, different ways of specifying the temporal component and to
evaluate how well the INLA approach fits LBSNs’ data. The best model uses as a target variable the logarithm of the density of the people in a certain area, and fully exploits the spatio-temporal information.

![Model structure](/images/formula1.PNG)

The variables of the modal can be studied separately. First, the posterior mean of the main
spatial effect ζ = exp(u<sub>i</sub> +v<sub>i</sub>) can be extracted and mapped, as we can see below. It is clear that the spatial effect is higher in the
Galleria Vittorio Emanuele area (the bluest rectangle), followed by Brera in the north
and the Basilica of San Lorenzo Maggiore area in the bottom left corner.

![Posterior mean of the spatial main effect ζ](/images/spatialmeaneffect.png)

The two temporal effect can be plotted as time series, as displayed below. The
structured effect, γt shows an increase towards the end of the year, while the unstructured
one, φt, captures well the monthly seasonality detected.

![Posterior temporal trend: unstructured effect φt as solid line and temporally structured
effect γt as dashed line.](/images/posteriortemporaltrend.png)

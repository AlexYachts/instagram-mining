# Mining Location-Based Social Networks: a Bayesian approach to Instagram’s API data

This repository includes code that I used for my Master Thesis: "Mining Location-Based Social Networks: a Bayesian approach to Instagram’s API data".

## Introduction
The purpose of the thesis is to show how a Location-Based Social Network (LBSN), such as Instagram, can be used to detect individuals’ presence and movements within the city of Milan. Instagram offers user-generated data about the presence of people in an area, since it provides the geographical
localisation of the picture; and the way individuals experience a place, thanks to
hashtags. The thesis shows how the data can be used to study movement patterns inside a city, through data visualisation
techniques and spatio-temporal models. On the methodological side, this is the first work (at the time of writing, 2015) that uses the Integrated Nested
Laplace Approximation method developed by [Rue, Martino, and Chopin (2009)](https://rss.onlinelibrary.wiley.com/doi/10.1111/j.1467-9868.2008.00700.x) to analyse
social media data. The approach was chosen as some of its features fit well
with the analytical framework of social media data. First, it is highly flexible in the
modeling phase of the analysis, thus allowing the researcher to tune the analysis
according to the characteristics of the data retrieved. For example, it allows the use
of different likelihood assumptions on the spatial point process and to easily add covariates
to the analysis. Furthermore, spatial and temporal dimensions can be fully exploited even
through the use of interactions. Diagnostic and model selection tools are also available,
so that the researcher can be guided in the process of adjusting the model. In addition,
the method provides the possibility of performing forecasting exercises, thus allowing to
understand the predictive power of the chosen models.
Finally, along with the quantitative approach, a more qualitative approach was also explored,
by the collection and geographical visualization of the user hashtags.

# Data Inspection

## Temporal Dimension
For my thesis, I extracted and analysed hundreds of thousands of pictures taken in the city of Milan by Instagram users over the course of 5 years.
The data shows power-law-like distributions, as [expected from Social Network data](https://www.cs.cornell.edu/home/kleinber/networks-book/networks-book-ch18.pdf). One example is the number of pictures per user.

![Frequency of number of pictures per user](/images/distribution.png)

Another typical pattern is the day/night variation. The two figures below display this intra-day fluctuations. The top one shows two peaks during a day, one around 13:00 and the other one around 18:00, while the polar coordinate graph highlights the difference between the activity during working hours (in dark blue) and free time (in light blue).

![Intra day trend, split by year](/images/hourpattern.png)
![Polar Coordinates representation of daily activity](/images/workhours.png)

## Spatial Dimension

As expected, pictures were mostly clustered in points of interest in the city (city center and the EXPO area).

![Spatial Distribution](/images/spatialdistribution.png)

## Spatio-Temporal Information
Similar patterns can be observed when one plots the data using both spatial and geographical information. Combining the two brings new insights and expected findings.
So, for example, the figure below shows the increasing usage of Instagram from 2010 to 2015,
but it also displays two other phenomena. First, while until 2013 users would take pictures mostly in the innermost part of the city, in 2015 pictures were taken on
the whole territory. Second, the event of the Universal Exposition 2015 (Expo 2015) was captured
by the LBSN data. Activity in that area (top left corner of the map) increased suddenly
in 2015.

![Spatio-temporal growth of Instagram](/images/mapsyearspoints.png)

A split of the year 2015 by month identifies the time range of the Expo event, which opened in May and ended in October.

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
to use them in the INLA approach, the process needs to be transformed into a discrete and
indexed spatio-temporal process. This transformation can be done by fitting data into pre-existing administrative boundaries. In the case of Milan, ISTAT provides
several types of urban administrative boundaries, such as NILs (local identity nuclei).
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
data on an hourly basis, one can see some interesting patterns, as the figure below displays. In
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

Where b<sub>0</sub> is an intercept, v<sub>i</sub>
is the area-specific effect modelled as exchangeable (v<sub>i</sub> ∼
Normal(0, σ<sup>2</sup>)) and ui
is another area-specific effect, modelled to take in consideration
the spatial structure. One of the several ways to model this spatial structure is the
intrinsic conditional autoregressive (iCAR) approach, which specifies ui
in the following way:

![u_i](/images/u_i.PNG)

where
* µ<sub>i</sub> is the mean for the area i
* s<sub>i</sub><sup>2</sup> = σ<sub>u</sub><sup>2</sup>/N<sub>i</sub> is the variance for the same area
* a<sub>ij</sub> takes value of 1 if areas i and j are neighbors and 0 otherwise (with a<sub>ii</sub> set to 0)

Modeling v<sub>i</sub> as exchangeable, together with the iCAR specification of u<sub>i</sub>, originates
what is known as the [Besag-York-Mollié (BYM) model](https://link.springer.com/article/10.1007/BF00116466).

The temporal component is specified using a dynamic nonparametric formulation
for the linear predictor, where γ<sub>t</sub>
is modelled dynamically, for example as γ<sub>t</sub>
|γ<sub>t-1</sub> ∼ Normal(γ<sub>t-1</sub>, σ<sup>2</sup>
), and φ<sub>t</sub> has
a Gaussian exchangeable prior, i.e. φ<sub>t</sub> ∼ Normal(0, 1/τ<sub>φ</sub>). In this way, the temporal part
is further decomposed in two main effect: γ<sub>t</sub>
, which is structured, and φ<sub>t</sub>
, which is left
unstructured.

The interaction between the spatial and the temporal
dimensions, δ<sub>it</sub>, is simply added to the model in a linear fashion.
δ<sub>it</sub> follows a Gaussian distribution with a
precision matrix that is equal to τ<sub>δ</sub>R<sub>δ</sub>. The precision matrix is, therefore, composed by
a scalar, τ<sub>δ</sub>, and a structure matrix, R<sub>δ</sub>, which can be factorised as a Kronecker product
of the structure matrices of the interacting effects. Now, the model has different temporal
and spatial effects, which implies that the interaction can occur in different ways. From
the spatial point of view, v<sub>i</sub> represents the unstructured effect, while u<sub>i</sub> the structured
one. Likewise, φ<sub>t</sub> doesn’t have a temporal structure, whereas γ<sub>t</sub>
is dynamically modelled.
Therefore, there are four different couples of spatial and temporal components that can
concur to define δ<sub>it</sub>. The simplest type of interaction, though, consists in interacting
the unstructered effects, v<sub>i</sub> and φ<sub>t</sub>
. The reason is that, being the two components not
structured, their structure matrices are identity matrices. This simplifies the calculation
of R<sub>δ</sub>, which is then:
R<sub>δ</sub> = R<sub>v</sub> ⊗ R<sub>φ</sub> = I ⊗ I = I
This means that the interaction term doesn’t have any spatial or temporal structure,
which boils down to assuming the following condition:
δ<sub>it</sub> ∼ Normal(0, 1/τ<sub>δ</sub>).

The variables of the model can be studied separately. First, the posterior mean of the main
spatial effect ζ = exp(u<sub>i</sub> +v<sub>i</sub>) can be extracted and mapped, as we can see below. It is clear that the spatial effect is higher in the
Galleria Vittorio Emanuele area (the bluest rectangle), followed by Brera in the north
and the Basilica of San Lorenzo Maggiore area in the bottom left corner.

![Posterior mean of the spatial main effect ζ](/images/spatialmeaneffect.png)

The two temporal effects can be plotted as time series, as displayed below. The
structured effect, γ<sub>t</sub> shows an increase towards the end of the year, while the unstructured
one, φ<sub>t</sub>, captures well a monthly seasonality.

![Posterior temporal trend: unstructured effect φ<sub>t</sub> as solid line and temporally structured
effect γ<sub>t</sub> as dashed line.](/images/posteriortemporaltrend.png)

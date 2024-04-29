# Lobster-ECOL README

<div class="cell-output-display">

<style type="text/css">/********** GMRI Rmarkdown Core Style Sheet - Do Not Modify!!! **********/
&#10;
/********** Begin Style Sheet **********/
&#10;/* Avenir Font from Fonts.com for GMRI Branding */
&#10;
&#10;
&#10;
/* PRE-Avenir Fonts: Lato + Raleway font import from google fonts */
@import url('https://fonts.googleapis.com/css?family=Lato');
@import url('https://fonts.googleapis.com/css?family=Raleway&display=swap');
&#10;/* add font families as needed: font-family: 'Lato', sans-serif; */
&#10;
/* Level 1 Headers */
h1 { text-align: left;
     margin: 10px 0 15px 0;
     margin-top: 40px;
     font-size: 38px;
     font-family: Lato;
}
&#10;
/* Headers 2 - 6 */
h2, h3, h4, h5, h6 {
    color: #333333;
    margin: 20px 0 5px 0;
    text-align: left;
    font-family: Lato;}
&#10;
/* Sizing/font For Each Header Type */
h2, .h2 { font-size: 24px; margin-top: 40px;}
h3, .h3 { font-size: 20px; margin-top: 40px;}
h4, .h4 { font-size: 18px;}
h5 { font-size: 16px; margin-top: 40px;font-weight: normal; color: #3069aa; text-decoration: underline;}
h6 { font-size: 14px; margin-top: 40px;font-weight: normal; color: #3069aa; }
&#10;
/* Paragraph Text */
p, ol { margin-top: 10px;
    font-family: 'Raleway', sans-serif;}
&#10;/* Figure & Table Captions */
figure, figcaption, .figure-caption {font-size: 12px; color: #5a6570}
caption {font-size: 12px; color: #5a6570}
&#10;
/* Title Author and Date Headers */
h1.title.toc-ignore {margin-top: 10px;}
h4.author, h4.date {
    color: rgb(0,115,109);
    margin-top: 0;
    margin-bottom: 5px;
    font-size: 12px;}
&#10;
&#10;/* Links */
a {
    color: rgb(234,79,18)
}
&#10;
/***********************************************/
&#10;
/********  Table of Contents  **********/
&#10;/* Highlighted TOC Element */
.list-group-item.active, .list-group-item.active:focus, .list-group-item.active:hover {
    z-index: 2;
    color: #fff;
    background-color: rgb(0,96,138);
    border-color: rgb(0,96,138);
}
&#10;/* Default TOC Elements */
.list-group-item, .list-group-item:focus, .list-group-item:hover {
    z-index: 2;
    color: rgb(0,96,138);
    background-color: #fff;
    border-color: rgb(0,96,138);
}
&#10;
/********  Tab Panels  **********/
&#10;/* Navigation Tabs - Highlighted Tabset Pills */
.nav-pills > li.active > a, .nav-pills > li.active > a:hover, .nav-pills > li.active > a:focus {
    color: #fff;
    background-color: rgb(0,115,109) ;
    }
&#10;/* Navigation Tabs - Default Tabset Pills */
.nav-pills > li > a, .nav-pills > li > a:hover, .nav-pills > li > a:focus {
    color: rgb(0,115,109);
    background-color: #fff;
    }
&#10;
/* Second Level Tabs - Active */
.nav-tabs > li.active  > a, .nav-tabs > li.active > a:hover, .nav-tabs > li.active > a:focus {
    color: #fff;
    background-color: rgb(83,83,83) ;
    }
&#10;/* Second Level Tabs - Inactive */
.nav-tabs > li  > a, .nav-tabs > li > a:hover, .nav-tabs > li > a:focus {
    color: rgb(83,83,83);
    background-color: #fff;
    }
&#10;
&#10;/********** End Core Style Sheet **********/
&#10;
&#10;</style>

</div>

# Lobster-ECOL

This is the ecological data processing code for the Lobster ecology
project. This project’s scope ranges across spatial scales working
outward from a nearshore area that is sampled with Maine’s ventless trap
survey (3nm), to an area that is further offshore but state managed
(6nm), and ultimately to t shelf-scale area that is sampled by the
Federal Government’s fisheries independent surveys.

At each of these spatial scales physical and ecological metrics have
processed for further use in research.Code in this repository covers the
acquisition and data processing of physical and ecological datasets at
the following scales and from the following sources:

# A.) Nearshore Scale Maine + New Hampshire Metrics:

![](README_files/figure-commonmark/unnamed-chunk-4-1.png)

### Local Currents

1.  Maine Coastal Current, Turnoff

> Source: FVCOM

#### Sea Surface Temperature

1.  SST Anomalies
2.  Days over 20 C
3.  Days within 12-18 C

> Source: FVCOM

#### Bottom Temperature

1.  BT Anomalies
2.  Days over 20 C
3.  Days within 12-18 C

> Source: FVCOM

------------------------------------------------------------------------

# B.) State/Regional Scale: Gulf of Maine, SNE & GB Metrics:

![](README_files/figure-commonmark/unnamed-chunk-5-1.png)

#### Sea Surface Temperature

1.  SST Anomalies  
2.  Days over 20 C
3.  Days within 12-18 C

> Source: FVCOM

#### Bottom Temperature

1.  BT Anomalies
2.  Days over 20 C
3.  Days within 12-18 C

> Source: FVCOM

#### Primary Productivity

1.  Annual PAR and photosynthetic efficiency

> Source: Ecodata

#### Zooplankton

1.  Annual abundance by taxa

> Source: Ecodata

#### Lobster Predator Indices

1.  Predator abundance
2.  Predator size spectra

> Sources: NEFSC & ME/NH Survey

#### Predator exploitation rate

1.  Based on rate as calculated in the 2020 lobster stock assessment as
    the annual catch of lobster divided by the estimate of population
    abundance

> Source: ASMFC 2020 lobster stock assesment

------------------------------------------------------------------------

# C.) Northeast US Shelf-wide Scale:

#### Gulf Stream Position

> Source: Ecodata

#### Sea Surface Temperature

1.  SST Anomalies
2.  Days over 20 C
3.  Days within 12-18 C

> Source: FVCOM

#### Bottom Temperature

1.  BT Anomalies
2.  Days over 20 C
3.  Days within 12-18 C

> Source: FVCOM

#### Salinity

> Only if requested Source: FVCOM

#### Currents

1.  Relative inflow of GS vs. Scotian Shelf water at NE Channel

> Source: ecodata::slopewater

# Lobster-ECOL Quarto Docs Directory

[Area Subsetting in R with
{FVCOM}](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/FVCOM_Area_Subsetting_Demo.html)

[Exploring Monthly File Contents and
Structures](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/FVCOM_GMRI-Monthly-Inventory-Check.html)

[Maine Coastal Current
Processing](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/FVCOM_MaineCoastalCurrent.html)

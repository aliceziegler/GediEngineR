// INPUT -------------------------------

// input granules
// granule format: ["Name", "Date"]


//var gedi_granules = require("users/Ludwigm6/gedi:gedi_granules")


var gedi_granules = require("users/alicezglr/default:GEDI/granule_list")
var group_granules = gedi_granules.granules

/*
var group_granules = [
[['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019253002511_O04210_02_T00809_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019282143448_O04669_03_T05171_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019302045500_O04973_02_T05384_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019212174240_O03585_03_T02952_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019243064956_O04059_03_T01897_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019322230752_O05295_03_T03121_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019150181219_O02623_03_T03717_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019124040434_O02210_02_T00029_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019294080952_O04851_02_T05583_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019280130418_O04637_02_T03364_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019305053754_O05020_03_T03595_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019328182331_O05385_02_T01115_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019287120954_O04745_03_T00917_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019223132943_O03753_03_T05186_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019275152858_O04561_02_T00656_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019189034415_O03219_03_T03947_02_003_01_V002']],
[['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019321204934_O05278_02_T05139_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019196225104_O03340_02_T04665_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019314000252_O05156_02_T01375_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019348115134_O05691_03_T03564_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019275170148_O04562_03_T04926_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019158131745_O02744_02_T00319_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019246025356_O04103_02_T03104_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019293103015_O04837_03_T04605_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019313022304_O05142_03_T04819_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019204193034_O03462_02_T00962_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019166130117_O02868_03_T02616_02_003_01_V002'],
['LARSE/GEDI/GEDI02_B_002/GEDI02_B_2019112075017_O02026_02_T00059_02_003_01_V002']]];
*/


// load hessen vector: AOI
//var hessen = ee.FeatureCollection("projects/ee-ludwigm6/assets/gedi_hessen/hessen");
var hessen = ee.FeatureCollection("users/alicezglr/hessen");

// FUNCTIONS ---------------------------

// define function for indices
var S2_SR_indices = function(img){

  var ndvi = img.expression('(NIR-RED)/(NIR+RED)', {
              'NIR': img.select('B8'),
              'RED': img.select('B4')
              }).multiply(10000).toInt16().rename('NDVI');

  var evi = img.expression(
      '2.5 * ((NIR - RED) / (NIR + 6 * RED - 7.5 * BLUE + 1))', {
      'NIR': img.select('B8'),
      'RED': img.select('B4'),
      'BLUE': img.select('B2')}).multiply(10000).toInt16().rename('EVI');

  var ireci = img.expression(
      '(NIR - RED)/(RE1/RE2)',{
        'NIR': img.select('B7'),
        'RED': img.select('B4'),
        'RE1': img.select('B5'),
        'RE2': img.select('B6')}).multiply(10000).toInt16().rename('IRECI');


    return img.addBands(ndvi).addBands(evi).addBands(ireci);
}

// define function for Sentinel 1
var sen1vvvh = function(image){

  var diff = image.select("VV").subtract(image.select("VH")).rename("VVsubVH")
  var rati = image.select("VV").divide(image.select("VH")).rename("VVdivVH")

  return image.addBands(diff).addBands(rati)

}

//define function to extract date of gedi orbit by name of gedi orbit
function name2date(namestring){
  var fulldt = namestring.split("_")[4].substr(0,7);
  var year = parseInt(fulldt.substr(0,4));
  var day = parseInt(fulldt.substr(4,7));
  var date = new Date(year, 0, day+1); //!!! az: I added the +1. JS community does without. But incorrect, right!?!?
  return(ee.Date(date))
}

// define function for cloud mask (based on SCL band)
var S2_SR_cloudmask = function (image) {
  var scl = image.select('SCL');
  var wantedPixels = scl.gt(3).and(scl.lt(7));//.or(scl.eq(1)).or(scl.eq(2));
  return image.updateMask(wantedPixels)
}


// COMPUTE --------------------------

var iterator = 0
// map over granule list
var results_group_granules = group_granules.map(function(granules){
  iterator = iterator + 1
var results = granules.map(function(g){

  // Load one GEDI orbit
  var gedi = ee.FeatureCollection(g[0]);
  //var gedi_date = ee.Date(g[1])
  var gedi_date = name2date(g[0])


  gedi = gedi.filterBounds(hessen)
  .filter(ee.Filter.eq("l2b_quality_flag", 1))
  .filter(ee.Filter.gt("sensitivity", 0.9))
  .filter(ee.Filter.neq("pai", null));
  /*
  // Filter a small amount of points in the orbit
  gedi = gedi.filterBounds(hessen).randomColumn();
  var gedi_sample = gedi.filter(ee.Filter.lt("random", 0.03));
  */
  //while testing:
  var gedi_sample = gedi
  // Buffer the points and add time as property
  gedi_sample = gedi_sample.map(function(f){return f.buffer(12.5).set({time: gedi_date})})
  //print(gedi_sample)

//print("gedi buffer size: ", gedi_sample.size())
//print(gedi_sample, "W Time")
    // calc time difference to gedi date
  var temporalMatch = function(image){
      var timediff = gedi_date.difference(ee.Date(image.get("system:time_start")), "day").abs()
      return image.set({timediff: timediff})
    };


  // Load Sentinel 2 Surface Reflectance and apply the filtering
  // Uses start and end date specified in the granule list
  var sen2 = ee.ImageCollection('COPERNICUS/S2_SR')
    .filterBounds(gedi_sample)
    .filterDate(gedi_date.advance(-5, "day"), gedi_date.advance(5, "day")) // +- 5 days of gedi orbit
    //.filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', 50)) // less than 80% cloud cover
    .select('B2', 'B3', 'B4', 'B5', 'B6', 'B7', 'B8', 'B8A', 'B9', 'B11', 'B12', 'SCL')
    .map(S2_SR_cloudmask)
    .map(function(image){
      var idate = ee.Number.parse(image.date().format("YYYYDDD"))
      var dateBand = ee.Image.constant(idate).uint32().rename('S2time')
      return(image.addBands(dateBand))
    })
    .map(S2_SR_indices)
    .map(temporalMatch)
    .sort("timediff")
    .mosaic()


  var sen1 = ee.ImageCollection("COPERNICUS/S1_GRD")
  .filterBounds(gedi_sample)
  .filterDate(gedi_date.advance(-3, "day"), gedi_date.advance(3, "day")) // +- 3 days of gedi orbit
  .filter(ee.Filter.listContains('transmitterReceiverPolarisation', "VV"))
  .filter(ee.Filter.listContains('transmitterReceiverPolarisation', "VH"))
  .filter(ee.Filter.eq('instrumentMode', 'IW'))
  .select("VV", "VH")
  .map(function(image){
      var idate = ee.Number.parse(image.date().format("YYYYDDD"));
      var dateBand = ee.Image.constant(idate).uint32().rename('S1time')
      return(image.addBands(dateBand))
    })
  .map(sen1vvvh)
  .map(temporalMatch)
  .sort("timediff")
  .mosaic();

  var stack = sen2.addBands(sen1)

  var sampledPoints = stack.sampleRegions({
  collection: gedi_sample,
  scale: 10,
  properties: ['time','pai', "beam", "degrade_flag", "l2b_quality_flag",
  "sensitivity", "shot_number", "solar_azimuth", "solar_elevation", "id"],
  geometries: true
})
/*
//visually check distribution of GEDI hulls
Map.centerObject(hessen)
var gediHull = gedi.geometry().convexHull();
Map.addLayer(gediHull, undefined, "gediHull");
*/
//print(g)
  //print("sampled_Points: ", sampledPoints.size())
  return sampledPoints

})

//print(results, "Sampled Points")



var resultsCollection = ee.FeatureCollection(results).flatten()
//print(resultsCollection.first(), "RES")


//print("size result collection: ", resultsCollection.size())

Export.table.toDrive({
    collection: resultsCollection,
    description: "Res",
    fileNamePrefix: "gedi_" + iterator,
    folder: "gedi"
  })

})

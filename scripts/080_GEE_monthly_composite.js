//////////////////////////////////////
//Description: recreate Model from R and compute spatial prediction (Marvin Ludwig)
/////////////////////////////////////

////////////////////////
//functions
///////////////////////
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

// define function for cloud mask (based on SCL band)
var S2_SR_cloudmask = function (image) {
  var scl = image.select('SCL');
  var wantedPixels = scl.gt(3).and(scl.lt(7));//.or(scl.eq(1)).or(scl.eq(2));
  return image.updateMask(wantedPixels)
}

////////////////////////
//variables
///////////////////////
var hessen = ee.FeatureCollection("users/alicezglr/hessen");

var train_data = ee.FeatureCollection("users/alicezglr/small_data_train");
//train_data = train_data.randomColumn();
//  var train_data_smpl = train_data.filter(ee.Filter.lt("random", 0.20));
//print(train_data)

var preds_s1 = ["VV", "VH"]
var preds_s2 = ["B4", "EVI", "B7", "B5", "B3", "B8", "B8A", "B6", "B2"]
var preds = ["B4", "VV", "EVI", "B7", "B5", "VH", "B3", "B8", "B8A", "B6", "B2"]


var months = [
["2021-01-01","2021-01-31"],
["2021-02-01","2021-02-28"],
['2021-03-01','2021-03-31'],
['2021-04-01','2021-04-30'],
['2021-05-01','2021-05-31'],
['2021-06-01','2021-06-30'],
['2021-07-01','2021-07-31'],
['2021-08-01','2021-08-31'],
['2021-09-01','2021-09-30'],
['2021-10-01','2021-10-31'],
['2021-11-01','2021-11-30'],
['2021-12-01','2021-12-31']];


////////////////////////
//regression
///////////////////////

var classifier = ee.Classifier.smileRandomForest(50, 2, 5, 0.5, null, 0)
.setOutputMode("REGRESSION")
    .train({
      features: train_data,
      classProperty: 'pai',
      inputProperties: preds
    });
print(classifier)


//Sen1/2 Material
var iterator = 0
var spat_pred_month = months.map(function(dates){
   iterator = iterator + 1

var sen2 = ee.ImageCollection('COPERNICUS/S2_SR')
    .filterBounds(hessen)
    .filterDate(dates[0], dates[1])
    .map(S2_SR_cloudmask)
    .map(S2_SR_indices)
    .select(preds_s2)
    .median();
//Map.addLayer(sen2)

var sen1 = ee.ImageCollection("COPERNICUS/S1_GRD")
  .filterBounds(hessen)
  .filterDate(dates[0], dates[1])
  .filter(ee.Filter.listContains('transmitterReceiverPolarisation', "VV"))
  .filter(ee.Filter.listContains('transmitterReceiverPolarisation', "VH"))
  .filter(ee.Filter.eq('instrumentMode', 'IW'))
  .select(preds_s1)
  .map(sen1vvvh)
  .median();
//Map.addLayer(sen1)

var stack = sen2.addBands(sen1)

Export.image.toDrive({
  image: stack,
  description: 'monthly_composite_' + iterator,
  region: hessen,
  scale: 100,
  fileFormat: "GeoTIFF",
  fileNamePrefix: 'monthly_composite_' + iterator,
  crs: "EPSG:4326",
  folder: "gedi",
});


})

var DZWaveForm = require('com.dezinezync.waveform');

// open a single window
var win = Ti.UI.createWindow({
	backgroundColor:'white'
});

var imageView1 = Ti.UI.createImageView({
	width: Ti.UI.FILL,
	height: 100,
	top: 20,
	backgroundColor: "#eeeeee",
	preventDefaultImage: true
});

var imageView2 = Ti.UI.createImageView({
	width: Ti.UI.FILL,
	height: 100,
	top: 140,
	backgroundColor: "#eeeeee",
	preventDefaultImage: true
});

var imageView3 = Ti.UI.createImageView({
	width: Ti.UI.FILL,
	height: 100,
	top: 260,
	backgroundColor: "#eeeeee",
	preventDefaultImage: true
});

win.add(imageView1);
win.add(imageView2);
win.add(imageView3);

win.addEventListener("open", function() {

	var file1 = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory+"/test1.m4a");
	var file2 = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory+"/test2.m4a");
	var file3 = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory+"/test3.m4a");
	
	imageView1.image = DZWaveForm.analyze(file1.resolve()); //Synchronous.
	imageView2.image = DZWaveForm.analyze(file2.resolve()); //Synchronous.
	imageView3.image = DZWaveForm.analyze(file3.resolve()); //Synchronous.

	/*if(image) {
		imageView.setImage(image);
	}*/

	//Ti.API.debug(typeof image);

});

win.open();
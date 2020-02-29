var vpWidth = 800;
var vpHeight = 400;
document.getElementById('canvas').width = vpWidth;
document.getElementById('canvas').height = vpHeight;

var viewPort = function() {
	this.canvas = document.getElementById('canvas');
	this.ctx = this.canvas.getContext('2d');
	this.clear = function() {
		this.ctx.clearRect(0, 0, vpWidth, vpHeight);
	}
}
var viewport = new viewPort();

offsetCalculator = function() {
	this.cycleSize = 400;
	this.samples = [];

	this.redraw = function() {
		offsetCalculator.sineWave();
		offsetCalculator.drawWaves();
	}

	this.sineWave = function() {
		var harmonicCount = document.getElementById("harmonics").value;
		var lutPositions = document.getElementById("lutPositions").value;
		var offsetList = document.getElementById("offsetList");
		var calcOffsets = document.getElementById("calcOffsets").checked;
		var outputHex = document.getElementById("outputHex").checked;
		offsetList.innerHTML = (outputHex ? '0000\r': '0,');;
			
		// Build master list of samples - each time an offset for the next harmonic is found it will be added to this list
		this.samples.length = 0;
		for (var s = 0; s < this.cycleSize; s++) {
			this.samples.push(Math.sin(s * (Math.PI * 2) / this.cycleSize)); 
		}

		// locate best position to minimise crest by testing each position for minimum vertical spread
		for (var harmonic = 2; harmonic <= harmonicCount; harmonic++) {
			var bestSpread = 999;
			var bestSpreadOffset = 0;

			for (var offset = 0; offset < this.cycleSize && calcOffsets; offset++) {
				var minSample = 0;
				var maxSample = 0;
				for (var s = 0; s < this.cycleSize; s++) {
					var testSample = this.samples[s] + Math.sin(harmonic * ((s + offset) * (Math.PI * 2) / this.cycleSize)); 
					if (testSample > maxSample) 
						maxSample = testSample;
					if (testSample < minSample) 
						minSample = testSample;
				}
				if (maxSample - minSample < bestSpread) {
					bestSpread = maxSample - minSample;
					bestSpreadOffset = offset;
				}

			}

			// Update master samples by summing with samples from next harmonic appropriately offset
			for (var s = 0; s < this.cycleSize; s++) {
				this.samples[s] = this.samples[s] + Math.sin(harmonic * ((s + bestSpreadOffset) * (Math.PI * 2) / this.cycleSize)); 
			}
			
			// add to offset list
			bestSpreadOffset = Math.floor((lutPositions / this.cycleSize) * bestSpreadOffset);

			var hex = bestSpreadOffset.toString(16).toUpperCase();
			hex = "0000".substr(0, 4 - hex.length) + hex;
		  
			offsetList.innerHTML += (outputHex ? hex + '\r': bestSpreadOffset + ',');

			//setTimeout(function() {offsetCalculator.drawWaves();}, 1000);
		}
	}

	this.drawWaves = function() {
		viewport.clear();
		context = viewport.ctx;
		var vertOffset = vpHeight / 2;

		// Draw zero line
		context.beginPath(); 
		context.moveTo(0, vertOffset);
		context.lineTo(800, vertOffset);
		context.strokeStyle = "grey";
		context.stroke();	

		var maxSample = 0;
		var minSample = 0
		for (var s = 0; s < this.samples.length; s++) {
			if (this.samples[s] > maxSample)
				maxSample = this.samples[s];
			if (this.samples[s] < minSample)
				minSample = this.samples[s];

			context.beginPath(); 
			context.moveTo(s * 2, vertOffset - (20 * this.samples[s]));
			context.lineTo((s + 1) * 2, vertOffset - (20 * this.samples[s + 1]));
			context.strokeStyle = "blue";
			context.stroke();
		}
		var spread = document.getElementById("spread");
		spread.innerHTML = "Spread: " + (maxSample - minSample).toFixed(3).toString();
	}

	this.copyVals = function() {
		var offsetList = document.getElementById("offsetList");
		offsetList.select();
  		document.execCommand('copy');
	}
}


var offsetCalculator = new offsetCalculator();
offsetCalculator.redraw();
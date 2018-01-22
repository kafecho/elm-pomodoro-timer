import './main.css';
import { Main } from './Main.elm';


var app = Main.embed(document.getElementById('root'));

// import registerServiceWorker from './registerServiceWorker';
// registerServiceWorker();

var AudioContext = window.AudioContext || window.webkitAudioContext;
var audioContext = new AudioContext();

var samples = {};

var notifySampleLoadingFailed = function(url){
  console.log("Unable to load the sample @", url);
};

/**
  * Decode a sample file into an audio buffer.
  * The audio buffer is kept in JavaScript memory (using a key to store / retrieve it).
  * This function takes an array of parameters, where:
  * - the 1st element is the alias of the sample to load (for example Kick or Snare).
  * - the 2nd element is the URL of the sample to load, for example "samples/Kick.wav".
  */
app.ports.loadSample.subscribe(function ( array ){
  var url = array[0];
  var key = array[1];

  console.log("Url", url);

  if (samples[key] == null){
    var request = new XMLHttpRequest();
    request.open('GET', url, true);
    request.responseType = 'arraybuffer';
    request.onload = function () {
        if (request.status === 200) {
            var audioData = request.response;
            audioContext.decodeAudioData(audioData,
                function (audioBuffer){
                    samples[key]=audioBuffer;
                    console.log("Loaded", key, url);
                },
                function (e){
                    notifySampleLoadingFailed(url);
                });
        }else {
            notifySampleLoadingFailed(url);
        }
    }

    request.onerror = function () {
        notifySampleLoadingFailed(url);
    }

    request.send();
  }
});

/**
  * Schedule the playback of an audio buffer at some point in the near future.
  * This function takes an array of parameters, where:
  * - the 1st element is the alias of the sample to play
  * - the 2nd element is a float value which indicates when in the future the playback should start.
  */
app.ports.playSample.subscribe(function (array){
    var key = array[0];
    var when = array[1];
    var source = audioContext.createBufferSource();
    source.buffer = samples[key];
    source.connect(audioContext.destination);
    source.start(when);
});


import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer player;
FFT fft;

//Initial variables
float baseRadius = 150;
int totalBands = 6;
float amplitudeMultiplier = 6;
float maxAmplitude = 150;
float lineThickness = 4;
float[] smoothedAmplitudes;

//random variables
float randomBandmultiplier = random(1,30);
float randomAmplitudeMultiplier =random(1,6);
float randomLineThickness = random(1,3);
float randomRed1 = random(100,256);
float randomRed2 = random(100,256);
float randomRed3 = random(100,256);
color randomColor = color(random(150, 256), random(150, 256), random(150, 256));


void setup() {
  size(800, 1000);
  minim = new Minim(this);

  // Load MP3 file
  player = minim.loadFile("A2 1.mp3");
  player.loop(); // Play the audio

  // Set up FFT
  fft = new FFT(player.bufferSize(), player.sampleRate());

  smoothedAmplitudes = new float[totalBands];
}

void draw() {
  background(randomColor);
  translate(width / 2, height / 2);

  fft.forward(player.mix);
  drawSoundwave();

  // Display current multipliers
  //drawMultiplierInfo();
}


/*void drawMultiplierInfo() {
  textAlign(CENTER, CENTER);
  textSize(20);
  fill(255); 
  text("Line Multiplier: " + nf(randomBandmultiplier, 1, 1), 0, height / 2 - 110);
  text("Line Thickness: " + nf(randomBandmultiplier, 1, 1), 0, height / 2 - 80);
}*/

void drawSoundwave() {
  strokeWeight(lineThickness*randomLineThickness);

  int adjustedBands = int(totalBands * randomBandmultiplier);
  adjustedBands = (adjustedBands / 3) * 3; // Makesure is a multiple of 3

  int lowBandCount = totalBands / 3;
  int midBandCount = totalBands / 3;
  int highBandCount = totalBands - (lowBandCount + midBandCount);

  int lowIndex = 0, midIndex = 0, highIndex = 0; // Track positions in each band category

  for (int i = 0; i < adjustedBands; i++) {
    int bandIndex = 0;
    color waveColor = color(255, 255, 255); // Default

    // Cycle graph  to ensures strict alternation
    switch (i % 3) {
      case 0: // Low frequency
        bandIndex = lowIndex % lowBandCount;
        waveColor = color(randomRed1, 0, 50);
        lowIndex++; // Move to the next low frequency
        break;
      case 1: // Mid frequency
        bandIndex = midIndex % midBandCount + lowBandCount;
        waveColor = color(randomRed2, 0, 100);
        midIndex++; // Move to the next mid frequency
        break;
      case 2: // High frequency
        bandIndex = highIndex % highBandCount + (lowBandCount + midBandCount);
        waveColor = color(randomRed3, 0, 50);
        highIndex++; // Move to the next high frequency
        break;

    }

    float angle = map(i, 0, adjustedBands, 0, TWO_PI);
    float rawAmplitude = fft.getBand(bandIndex) * amplitudeMultiplier*randomAmplitudeMultiplier;
    rawAmplitude = constrain(rawAmplitude, 0, maxAmplitude);

   if (rawAmplitude > smoothedAmplitudes[i % totalBands]) {
        smoothedAmplitudes[i % totalBands] = lerp(smoothedAmplitudes[i % totalBands], rawAmplitude, 0.01);
    } else {
      smoothedAmplitudes[i % totalBands] = lerp(smoothedAmplitudes[i % totalBands], rawAmplitude, 0.025);
    }

    stroke(waveColor);
    drawLine(baseRadius, smoothedAmplitudes[i % totalBands], angle);
  }
}

void drawLine(float startRadius, float amplitude, float angle) {
  float x1 = startRadius * cos(angle);
  float y1 = startRadius * sin(angle);
  float x2 = (startRadius + amplitude) * cos(angle);
  float y2 = (startRadius + amplitude) * sin(angle);

  line(x1, y1, x2, y2);
}

void stop() {
  player.close();
  minim.stop();
  super.stop();
}

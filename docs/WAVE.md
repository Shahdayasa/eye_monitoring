# Signal Processing and Waveform Guide --- EOG Wearable Fatigue Detection

> Project working title: **AI-Based Wearable Eye Fatigue Detection System**  
> This document covers EOG signal characteristics, preprocessing, feature extraction, and waveform visualization.

## 1. Introduction to EOG Signals

### What is EOG?

Electrooculography (EOG) is a technique for measuring the corneo-retinal standing potential that exists between the front and back of the human eye. The resulting signal is related to eye movement and blink activity.

### How EOG Works

- The eye acts as a dipole with the cornea (front) being positive and the retina (back) being negative
- When the eye moves, this dipole rotates, creating a measurable voltage change
- Electrodes placed around the eye detect these voltage changes

### EOG in This Project

This project uses **vertical EOG (VOEG)** to measure:
- Vertical eye movements
- Blink events
- Patterns associated with eye closure during fatigue

**Electrode Placement**: 
- One electrode above the eye (on the eyebrow or forehead)
- One electrode below the eye (on the cheek)
- Reference electrode near the mastoid/behind the ear

## 2. Signal Characteristics

### Typical EOG Signal Properties

| Property | Typical Range | Notes |
|----------|---------------|-------|
| Amplitude | 50-1000 µV | Depends on eye movement angle |
| Frequency band | 0.1-30 Hz | Main energy below 15 Hz |
| Blink duration | 100-400 ms | Rapid deflection |
| Sampling rate | 64-256 Hz | Must be at least 2x max frequency |

### Signal Sources

#### Blink Events
- Large amplitude deflections (200-1000 µV)
- Duration: 100-400 ms
- Characteristic shape: rapid up/down or down/up deflection

#### Eye Movements
- Saccades: fast movements (20-100 ms)
- Smooth pursuit: slower tracking movements
- Fixations: relatively stable periods

#### Fatigue-Related Patterns
- Increased blink rate
- Longer blink duration
- Slower eye movements
- Changes in pupil-related signals (if measurable)

### Noise Sources

#### Biological Noise
- EEG (brain signals)
- EMG (muscle activity, especially facial)
- ECG (heart signals, if electrodes are positioned to pick them up)
- Pulse artifacts

#### Environmental Noise
- 50/60 Hz power line interference
- Electrode motion artifacts
- Skin impedance changes
- Ambient electromagnetic fields

#### Hardware Noise
- ADC quantization noise
- Thermal noise from amplifiers
- Power supply noise

## 3. Signal Acquisition

### BioAmp EXG Pill Configuration

The BioAmp EXG Pill is the analog front-end for EOG acquisition.

#### Key Specifications to Verify
- Input voltage range: 4.5-40V (verify meaning with documentation)
- Gain settings
- Filter characteristics (hardware filters)
- Output voltage range

#### Connection to ESP32

```
BioAmp EXG Pill Output → ESP32 ADC Input
```

**Critical**: 
- Verify voltage levels are compatible with ESP32 ADC input (0-3.3V typical)
- Ensure proper grounding
- Check that signal is within ADC range

### ESP32 ADC Configuration

#### ADC Settings
```dart
// Example configuration (verify with actual hardware)
const adcConfig = {
  samplingRate: 128,        // Hz
  resolution: 12,           // bits (0-4095)
  attenuation: ADC_11db,    // For full 0-3.3V range
  channel: ADC1_CHANNEL_0,  // GPIO36
};
```

#### Sampling Considerations
- Use timer-based sampling for consistent intervals
- Implement DMA or double-buffering if available
- Record actual sampling rate for validation
- Handle missed samples gracefully

### Data Format

#### Raw ADC Values
- Integer values: 0-4095 (12-bit)
- Must be converted to voltage or normalized units
- Document the conversion formula

#### Voltage Conversion (Example)
```
voltage = (adc_value / 4095.0) * 3.3  // Volts
```

#### Normalized Units
```
normalized = (adc_value - offset) / scale_factor
```

## 4. Signal Preprocessing

### Preprocessing Pipeline

```
Raw Signal
    ↓
[1] DC Offset Removal
    ↓
[2] Bandpass Filtering (0.5-15 Hz)
    ↓
[3] Notch Filter (50/60 Hz) - Optional
    ↓
[4] Normalization
    ↓
[5] Windowing
    ↓
Preprocessed Signal
```

### Step 1: DC Offset Removal

**Purpose**: Remove the DC component (baseline shift) from the signal.

**Methods**:
- High-pass filtering (very low cutoff, e.g., 0.1 Hz)
- Mean subtraction
- Detrending

**Implementation**:
```python
import numpy as np
from scipy import signal

def remove_dc_offset(signal_data):
    """Remove DC offset by subtracting mean."""
    return signal_data - np.mean(signal_data)
```

### Step 2: Bandpass Filtering

**Purpose**: Remove frequencies outside the EOG band of interest (0.5-15 Hz).

**Filter Design**:
```python
def design_bandpass_filter(lowcut=0.5, highcut=15.0, fs=128, order=4):
    """Design a Butterworth bandpass filter."""
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = signal.butter(order, [low, high], btype='band')
    return b, a

def apply_bandpass_filter(signal_data, fs=128):
    """Apply bandpass filter to signal."""
    b, a = design_bandpass_filter(fs=fs)
    filtered = signal.filtfilt(b, a, signal_data)
    return filtered
```

**Considerations**:
- Use zero-phase filtering (filtfilt) to avoid phase distortion
- Choose appropriate filter order (higher = steeper rolloff but more computation)
- Verify filter stability

### Step 3: Notch Filter (Optional)

**Purpose**: Remove power line interference (50 Hz or 60 Hz depending on region).

**When to Use**:
- If power line noise is visible in the signal
- If hardware filtering is insufficient

**Implementation**:
```python
def design_notch_filter(freq=50.0, fs=128, quality=30.0):
    """Design a notch filter to remove specific frequency."""
    nyq = 0.5 * fs
    b, a = signal.iirnotch(freq / nyq, quality)
    return b, a

def apply_notch_filter(signal_data, freq=50.0, fs=128):
    """Apply notch filter to remove power line interference."""
    b, a = design_notch_filter(freq=freq, fs=fs)
    filtered = signal.filtfilt(b, a, signal_data)
    return filtered
```

### Step 4: Normalization

**Purpose**: Scale signal to consistent range for model input.

**Methods**:
- Min-max normalization
- Z-score standardization
- Robust scaling (using median and IQR)

**Implementation**:
```python
def z_score_normalize(signal_data):
    """Normalize using z-score standardization."""
    mean = np.mean(signal_data)
    std = np.std(signal_data)
    if std == 0:
        return signal_data
    return (signal_data - mean) / std

def min_max_normalize(signal_data):
    """Normalize to [0, 1] range."""
    min_val = np.min(signal_data)
    max_val = np.max(signal_data)
    if max_val == min_val:
        return signal_data
    return (signal_data - min_val) / (max_val - min_val)
```

**Important**: 
- Fit normalization parameters on training data only
- Apply same transformation to validation/test data
- Save normalization parameters with model artifacts

### Step 5: Windowing

**Purpose**: Segment continuous signal into fixed-length windows for analysis.

**Parameters**:
- Window duration (e.g., 10 seconds)
- Overlap (e.g., 50% overlap)
- Window function (optional: Hanning, Hamming, etc.)

**Implementation**:
```python
def create_windows(signal_data, window_size, overlap=0.5):
    """Create overlapping windows from signal."""
    step_size = int(window_size * (1 - overlap))
    windows = []
    
    for i in range(0, len(signal_data) - window_size + 1, step_size):
        window = signal_data[i:i + window_size]
        windows.append(window)
    
    return np.array(windows)
```

## 5. Feature Extraction

### Time-Domain Features

#### Statistical Features
```python
def extract_time_features(signal_window):
    """Extract time-domain features from signal window."""
    features = {
        'mean': np.mean(signal_window),
        'std': np.std(signal_window),
        'variance': np.var(signal_window),
        'min': np.min(signal_window),
        'max': np.max(signal_window),
        'range': np.max(signal_window) - np.min(signal_window),
        'median': np.median(signal_window),
        'skewness': scipy.stats.skew(signal_window),
        'kurtosis': scipy.stats.kurtosis(signal_window),
        'rms': np.sqrt(np.mean(np.square(signal_window))),
        'zero_crossings': np.sum(np.diff(np.sign(signal_window)) != 0),
    }
    return features
```

#### Blink-Related Features
```python
def detect_blinks(signal_window, threshold=3.0):
    """Detect blink events based on amplitude threshold."""
    mean = np.mean(signal_window)
    std = np.std(signal_window)
    
    # Simple threshold-based detection
    blink_indices = np.where(
        np.abs(signal_window - mean) > threshold * std
    )[0]
    
    # Group consecutive indices into blink events
    blink_events = group_consecutive(blink_indices)
    
    return {
        'blink_count': len(blink_events),
        'blink_rate': len(blink_events) / len(signal_window),
        'avg_blink_duration': np.mean([len(e) for e in blink_events]) if blink_events else 0,
    }
```

### Frequency-Domain Features

#### Power Spectral Density
```python
def extract_frequency_features(signal_window, fs=128):
    """Extract frequency-domain features."""
    # Compute PSD
    freqs, psd = signal.welch(signal_window, fs=fs, nperseg=len(signal_window))
    
    # Band power in different frequency ranges
    features = {
        'delta_power': band_power(freqs, psd, 0.5, 4),
        'theta_power': band_power(freqs, psd, 4, 8),
        'alpha_power': band_power(freqs, psd, 8, 13),
        'beta_power': band_power(freqs, psd, 13, 30),
        'total_power': np.sum(psd),
        'peak_frequency': freqs[np.argmax(psd)],
    }
    return features

def band_power(freqs, psd, low_freq, high_freq):
    """Calculate power in a specific frequency band."""
    band_mask = (freqs >= low_freq) & (freqs <= high_freq)
    return np.trapz(psd[band_mask], freqs[band_mask])
```

### Feature Selection

**Considerations**:
- Start with a reasonable set of features
- Use feature importance analysis
- Remove highly correlated features
- Validate feature relevance to fatigue

## 6. Signal Quality Assessment

### Quality Metrics

#### Signal-to-Noise Ratio (SNR)
```python
def calculate_snr(signal_window):
    """Estimate signal-to-noise ratio."""
    # Simple SNR estimation
    signal_power = np.var(signal_window)
    
    # Estimate noise from high-frequency components
    high_freq = highpass_filter(signal_window, cutoff=15.0)
    noise_power = np.var(high_freq)
    
    if noise_power == 0:
        return float('inf')
    
    snr = 10 * np.log10(signal_power / noise_power)
    return snr
```

#### Impedance Check
- Monitor baseline impedance if hardware supports it
- Flag high-impedance connections
- Alert user to check electrode contact

#### Motion Artifact Detection
```python
def detect_motion_artifacts(signal_window, threshold=5.0):
    """Detect potential motion artifacts."""
    # Large, rapid changes may indicate motion artifacts
    diff = np.abs(np.diff(signal_window))
    max_change = np.max(diff)
    
    # Compare to expected EOG amplitude
    expected_range = np.std(signal_window) * 4
    
    if max_change > threshold * expected_range:
        return True, max_change
    
    return False, max_change
```

### Quality Flags

```python
class SignalQuality:
    EXCELLENT = "excellent"
    GOOD = "good"
    POOR = "poor"
    UNUSABLE = "unusable"

def assess_signal_quality(signal_window):
    """Assess overall signal quality."""
    snr = calculate_snr(signal_window)
    has_artifacts, artifact_level = detect_motion_artifacts(signal_window)
    
    if snr < 5 or has_artifacts:
        return SignalQuality.UNUSABLE
    elif snr < 10:
        return SignalQuality.POOR
    elif snr < 20:
        return SignalQuality.GOOD
    else:
        return SignalQuality.EXCELLENT
```

## 7. Waveform Visualization

### Flutter Implementation

#### Waveform Painter
```dart
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> samples;
  final Color color;
  final double strokeWidth;
  
  WaveformPainter({
    required this.samples,
    this.color = Colors.teal,
    this.strokeWidth = 2.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    
    // Find min and max for scaling
    final minSample = samples.reduce((a, b) => a < b ? a : b);
    final maxSample = samples.reduce((a, b) => a > b ? a : b);
    final range = maxSample - minSample;
    
    // Draw waveform
    for (int i = 0; i < samples.length; i++) {
      final x = (i / (samples.length - 1)) * size.width;
      final y = size.height - ((samples[i] - minSample) / range) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return samples != oldDelegate.samples;
  }
}
```

#### Waveform Widget
```dart
class WaveformDisplay extends StatelessWidget {
  final List<double> samples;
  final String label;
  final String unit;
  
  const WaveformDisplay({
    Key? key,
    required this.samples,
    required this.label,
    this.unit = 'mV',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ($unit)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            size: Size.infinite,
            painter: WaveformPainter(
              samples: samples,
              color: Colors.teal,
            ),
          ),
        ),
      ],
    );
  }
}
```

### Visualization Best Practices

1. **Clear Axes**: Label x-axis (time) and y-axis (amplitude)
2. **Appropriate Scaling**: Auto-scale or use consistent scaling
3. **Grid Lines**: Optional, but helpful for reading values
4. **Time Window**: Show appropriate time window (e.g., last 10 seconds)
5. **Update Rate**: Update display at reasonable rate (e.g., 10-30 Hz)
6. **Color Coding**: Use distinct colors for different signals
7. **Annotations**: Mark events like blinks or predictions

## 8. Ambient Light Integration

### VEML7700 Sensor

#### Purpose
- Measure ambient light level
- Provide context for EOG readings
- Not a direct fatigue indicator

#### Reading Integration
```dart
// Example: Combine EOG and light data
class SensorReading {
  final List<double> eogSamples;
  final double ambientLightLux;
  final DateTime timestamp;
  
  SensorReading({
    required this.eogSamples,
    required this.ambientLightLux,
    required this.timestamp,
  });
}
```

#### Display
- Show light level separately from EOG
- Label clearly in lux (if calibrated)
- Use as contextual information, not for inference (unless model uses it)

## 9. Testing and Validation

### Signal Acquisition Tests

1. **Verify Sampling Rate**
   - Measure actual sampling interval
   - Confirm matches expected rate
   - Document any variations

2. **Verify ADC Resolution**
   - Test with known voltage levels
   - Confirm bit resolution
   - Check linearity

3. **Test Signal Path**
   - Inject known test signal
   - Verify correct amplitude
   - Check frequency response

### Preprocessing Tests

1. **Filter Validation**
   - Test with synthetic signals
   - Verify frequency response
   - Check for artifacts

2. **Normalization Tests**
   - Verify output range
   - Check edge cases (constant signal, zero variance)

3. **Windowing Tests**
   - Verify window size
   - Check overlap calculation
   - Test edge cases

### Quality Assessment Tests

1. **Noise Injection**
   - Add known noise levels
   - Verify quality metrics
   - Test artifact detection

2. **Edge Cases**
   - Empty signal
   - Constant signal
   - Very noisy signal
   - Missing samples

## 10. Open Questions

The team must confirm:

- [ ] Exact sampling rate and ADC configuration
- [ ] Hardware filter characteristics (if any)
- [ ] Final electrode placement
- [ ] Signal units (raw ADC, voltage, or normalized)
- [ ] Window duration and overlap for inference
- [ ] Whether to implement real-time blink detection
- [ ] Signal quality thresholds
- [ ] How to handle missing or corrupted samples

## 11. Key Principles

1. **Document Everything**: Record all signal processing parameters
2. **Validate End-to-End**: Test from hardware to model input
3. **Preserve Signal Integrity**: Avoid unnecessary transformations
4. **Handle Edge Cases**: Robust error handling for bad data
5. **Reproducibility**: Ensure preprocessing is deterministic
6. **Safety**: Never present raw signals as medical data

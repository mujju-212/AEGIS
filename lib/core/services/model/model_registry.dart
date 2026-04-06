import 'package:privacy_ai/core/services/device/device_capability_service.dart';

class ModelOption {
  final String id;
  final String name;
  final String description;
  final String size;
  final String ram;
  final String speed;
  final String? badge;
  final String downloadUrl;

  const ModelOption({
    required this.id,
    required this.name,
    required this.description,
    required this.size,
    required this.ram,
    required this.speed,
    required this.downloadUrl,
    this.badge,
  });
}

class ModelRegistry {
  static const _tinyLlama = ModelOption(
    id: 'tinyllama-1.1b-q4',
    name: 'TinyLlama 1.1B (Q4)',
    description: 'Fastest, lowest resource usage. Best for low-end devices.',
    size: '~637 MB',
    ram: '~1.5 GB',
    speed: 'Very Fast',
    badge: 'Fastest',
    downloadUrl:
        'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf',
  );

  static const _gemma2b = ModelOption(
    id: 'gemma-2b-q4',
    name: 'Gemma 2B (Q4)',
    description: 'Balanced quality and speed for most devices.',
    size: '~1.4 GB',
    ram: '~2.5 GB',
    speed: 'Medium',
    badge: 'Recommended',
    downloadUrl:
        'https://huggingface.co/TheBloke/gemma-2b-it-GGUF/resolve/main/gemma-2b-it.Q4_K_M.gguf',
  );

  static const _phi3mini = ModelOption(
    id: 'phi-3-mini-q4',
    name: 'Phi-3 Mini 3.8B (Q4)',
    description: 'Smarter reasoning, best for 8 GB devices.',
    size: '~2.2 GB',
    ram: '~3.0 GB',
    speed: 'Medium',
    badge: 'Smartest',
    downloadUrl:
        'https://huggingface.co/TheBloke/Phi-3-mini-4k-instruct-GGUF/resolve/main/phi-3-mini-4k-instruct.Q4_K_M.gguf',
  );

  static List<ModelOption> forTier(DeviceTier tier) {
    switch (tier) {
      case DeviceTier.low:
        return [_tinyLlama];
      case DeviceTier.mid:
        return [_gemma2b, _tinyLlama];
      case DeviceTier.upperMid:
        return [_gemma2b, _phi3mini];
      case DeviceTier.flagship:
        return [_phi3mini, _gemma2b, _tinyLlama];
    }
  }

  static ModelOption byId(String id) {
    for (final option in [_tinyLlama, _gemma2b, _phi3mini]) {
      if (option.id == id) return option;
    }
    return _gemma2b;
  }
}

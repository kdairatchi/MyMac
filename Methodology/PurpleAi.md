# Awesome AI Purple Teaming for LLM Security 🛡️

A comprehensive curated list of open-source tools, frameworks, and resources for AI Purple Teaming focused specifically on Large Language Model (LLM) security. This collection provides a balanced mix of offensive (red team) and defensive (blue team) capabilities for security practitioners, researchers, and developers working on LLM security.

## Table of Contents

- [Offensive Tools (Red Team)](#offensive-tools-red-team)
- [Defensive Tools (Blue Team)](#defensive-tools-blue-team)
- [Comprehensive Frameworks](#comprehensive-frameworks)
- [Educational Resources](#educational-resources)
- [Emerging & Specialized Tools](#emerging--specialized-tools)
- [Integration & CI/CD](#integration--cicd)
- [Contributing](#contributing)

## Offensive Tools (Red Team)

### Prompt Injection Testing

- **[DeepTeam](https://github.com/confident-ai/deepteam)** - Comprehensive open-source LLM red teaming framework with 40+ vulnerabilities and 10+ attack methods. Features single-turn and multi-turn prompt injection attacks, OWASP Top 10 compliance, and YAML configuration support.

- **[Spikee](https://github.com/spikee-ai/spikee)** - Simple Prompt Injection Kit for Evaluation and Exploitation with targeted attack capabilities. Includes Burp Suite integration, dynamic attack strategies, and data exfiltration testing via markdown images.

- **[promptmap2](https://github.com/utkusen/promptmap)** - Vulnerability scanner with dual-LLM architecture featuring 50+ pre-built test rules across 6 categories. Supports OpenAI, Anthropic, Google, XAI, and Ollama models with SAST/DAST hybrid approach.

- **[Rebuff](https://github.com/protectai/rebuff)** - Multi-layered defense framework that can also be used for testing prompt injection attacks. Features 4-layer defense with heuristics, LLM-based detection, VectorDB, and canary tokens.

### LLM Jailbreaking

- **[JailbreakBench](https://github.com/JailbreakBench/jailbreakbench)** - Open robustness benchmark for systematic jailbreaking evaluation with 200 distinct behaviors dataset. Includes official leaderboard and human/LLM judge evaluation system.

- **[PAIR (Prompt Automatic Iterative Refinement)](https://github.com/patrickrchao/JailbreakingLLMs)** - Black-box jailbreaking algorithm using attacker LLM to generate semantic jailbreaks. Works with <20 queries and achieves high success rates on major LLMs.

- **[JailTrickBench](https://github.com/usail-hkust/JailTrickBench)** - Comprehensive benchmarking framework with 7+ attack methods including DrAttack and MultiJail, plus 6+ defense methods. Features multilingual support across 10 languages.

- **[LLM Adaptive Attacks](https://github.com/tml-epfl/llm-adaptive-attacks)** - Simple adaptive attacks achieving near 100% success rates on safety-aligned LLMs through logprobs-based attacks and transfer techniques.

### Adversarial Testing

- **[PyRIT](https://github.com/Azure/PyRIT)** - Microsoft's official Python Risk Identification Tool for generative AI red teaming. Enterprise-ready framework with multi-turn conversation support and cloud service integration.

- **[LLMart](https://github.com/IntelLabs/LLMart)** - Intel's LLM Adversarial Robustness Toolkit with parallelized optimization. Features PyTorch and Hugging Face integrations with GPU acceleration support.

- **[TextAttack](https://github.com/QData/TextAttack)** - Comprehensive framework for adversarial text generation and NLP vulnerability testing with multiple attack algorithms and data augmentation capabilities.

### Model Extraction & Data Poisoning

- **[Giskard](https://www.giskard.ai/)** - Comprehensive LLM vulnerability scanning with data poisoning detection, heuristics-based detectors, and automated evaluation for enterprise applications.

- **[FuzzyAI](https://cyberarktechnologies.com/fuzzyai/)** - Comprehensive LLM fuzzing framework with GUI and CLI modes, featuring 15+ attacking methods and support for various model providers.

## Defensive Tools (Blue Team)

### Safety Evaluation Frameworks

- **[DeepEval](https://github.com/confident-ai/deepeval)** - Open-source LLM evaluation framework with 14+ research-backed metrics including G-Eval, hallucination detection, bias, and toxicity testing. Features CI/CD integration and production monitoring.

- **[PromptFoo](https://www.promptfoo.dev/)** - Comprehensive CLI and library for LLM security testing with adaptive red teaming using industry-specific attacks rather than generic responses.

- **[Evidently AI](https://www.evidentlyai.com/)** - Open-source monitoring and evaluation platform with custom LLM-as-a-judge implementations, semantic similarity evaluation, and live monitoring dashboards.

- **[TruLens](https://github.com/truera/trulens)** - Open-source framework for LLM transparency and interpretability with feedback functions for real-time evaluation of bias, toxicity, and accuracy.

### Content Filtering & Guardrails

- **[Guardrails AI](https://github.com/guardrails-ai/guardrails)** - Python framework for building reliable AI applications with input/output guards. Features 24+ pre-built validators, real-time streaming validation, and REST API compatibility.

- **[NeMo Guardrails](https://github.com/NVIDIA-NeMo/Guardrails)** - NVIDIA's open-source toolkit with 5 types of rails (Input, Dialog, Retrieval, Execution, Output). Features Colang modeling language and built-in guardrails for jailbreak detection.

- **[Purple Llama](https://github.com/meta-llama/PurpleLlama)** - Meta's open-source LLM safety tools suite including Llama Guard for moderation, Prompt Guard for malicious prompt detection, and Code Shield for insecure code detection.

### Monitoring & Detection

- **[LLM Guard](https://github.com/protectai/llm-guard)** - Enterprise-grade security toolkit with 15+ security scanners for real-time threat detection, PII anonymization, and integration with major LLM frameworks.

- **[Vigil LLM](https://github.com/deadbits/vigil-llm)** - Python library and REST API using vector databases, YARA heuristics, and transformer models for prompt injection detection with canary token integration.

### Output Validation

- **[Instructor](https://python.useinstructor.com/)** - Library for structured data extraction with Pydantic-based schema validation, automatic retries, and support for 15+ LLM providers.

## Comprehensive Frameworks

### Testing Platforms

- **[CyberSecEval](https://github.com/meta-llama/PurpleLlama)** - Meta's comprehensive cybersecurity evaluation suite with MITRE ATT&CK framework-based testing, prompt injection detection, and false refusal rate testing.

- **[OWASP LLM Security Verification Standard (LLMSVS)](https://owasp.org/www-project-llm-verification-standard/)** - Open security standard providing comprehensive guidelines for designing, building, and testing robust LLM applications with penetration testing methodologies.

- **[garak](https://github.com/leondz/garak)** - Generative AI Red-teaming and Assessment Kit for structured vulnerability discovery with generators, probes, detectors, and buffs architecture.

### Purple Teaming Platforms

- **[Mindgard](https://www.mindgard.ai/)** - AI-powered red teaming platform bridging offensive and defensive strategies with continuous automated red teaming (CART) capabilities.

### Benchmark Suites

- **[SECURE](https://arxiv.org/abs/2405.20441)** - Security Extraction, Understanding & Reasoning Evaluation benchmark focusing on Industrial Control Systems security across six datasets.

- **[CTIBench](https://arxiv.org/abs/2405.20441)** - Novel benchmark suite for cyber threat intelligence applications with four-component evaluation framework and multi-language support.

## Educational Resources

### Learning Platforms & Courses

- **[Microsoft AI Red Team Training Series](https://learn.microsoft.com/en-us/security/ai-red-team/training)** - Comprehensive 10-episode training series with hands-on demonstrations and PyRIT automation tool integration.

- **[HTB Academy - AI Red Teamer Path](https://academy.hackthebox.com/path/preview/ai-red-teamer)** - Practical training course in collaboration with Google, aligned with Google's SAIF framework.

- **[DeepLearning.AI - Red Teaming LLM Applications](https://www.deeplearning.ai/short-courses/red-teaming-llm-applications/)** - Beginner-friendly course on LLM security testing with Giskard integration and practical demonstrations.

### Challenge Sets & CTFs

- **[Stark Game](https://stark.trustai.pro/)** - Browser-based LLM security CTF with OWASP Top 10 based challenges, no signup required, focusing on prompt injection techniques.

- **[NYU CTF Bench](https://nyu-llm-ctf.github.io/)** - Scalable benchmark for evaluating LLMs in offensive security using real CTF challenges with leaderboard system.

- **[IEEE SaTML LLM CTF](https://ctf.spylab.ai/)** - Large-scale defense and attack competition with 72 defenses and 144,838 adversarial chats dataset.

### Datasets & Benchmarks

- **[deepset/prompt-injections](https://huggingface.co/datasets/deepset/prompt-injections)** - High-quality binary classification dataset for prompt injection detection with multilingual support.

- **[MLCommons AI Safety v1.0](https://mlcommons.org/benchmarks/ai-safety/)** - Standardized safety benchmark for chat-tuned LLMs with 43,090+ test items and open evaluation platform.

- **[CodeLMSec Benchmark](https://codelmsec.github.io/)** - Evaluates security vulnerabilities in code generation models with 280 non-secure prompts and CodeQL integration.

### Knowledge Collections

- **[Awesome LLM Security](https://github.com/corca-ai/awesome-llm-security)** - Curated collection of 200+ research papers, tools, defense mechanisms, and real-world examples.

- **[Awesome LLM Red Teaming](https://github.com/user1342/Awesome-LLM-Red-Teaming)** - Community-maintained list of 50+ tools, attack methodologies, research papers, and tutorials.

## Emerging & Specialized Tools

### Privacy-Focused Tools

- **[VaultGemma](https://research.google/)** - Google's 1B-parameter differentially private LLM preventing individual data exposure with formal privacy guarantees (ε ≤ 2.0, δ ≤ 1.1e-10).

- **[OneShield Privacy Guard](https://arxiv.org/abs/2501.12456v1)** - Advanced framework with multilingual PII detection across 26 languages, achieving 95% F1 score and outperforming existing solutions by up to 12%.

### Supply Chain Security

- **[HiddenLayer Model Scanner](https://azure.microsoft.com/en-us/products/ai-services/)** - Integrated with Microsoft Azure AI for deep structural analysis of AI models, scanning for malware, CVEs, and integrity issues.

- **[Awesome LLM Supply Chain Security](https://github.com/ShenaoW/awesome-llm-supply-chain-security)** - Comprehensive resource tracking 15+ CVEs, attack vectors including GGUF format exploits, and Hugging Face vulnerabilities.

### Model Interpretability

- **[HiddenLayer Policy Puppetry Detection](https://github.com/randalltr/universal-llm-jailbreak-hiddenlayer)** - Reveals how LLMs process structured data formats as internal policies, demonstrating universal bypass techniques across major LLMs.

### Specialized Scanners

- **[LLMFuzzer](https://github.com/mnns/LLMFuzzer)** - Open-source fuzzing framework specifically designed for testing LLMs and API integrations with modular architecture and autonomous attack modes.

## Integration & CI/CD

### Continuous Testing

- **[Promptfoo CI/CD Integration](https://www.promptfoo.dev/docs/integrations/github-action)** - GitHub Actions, GitLab CI, and Jenkins support for automated LLM evaluation with security vulnerability scanning and quality gate enforcement.

- **[Evidently AI GitHub Actions](https://github.com/evidentlyai/evidently)** - Native GitHub Actions integration for automated LLM testing with comprehensive reporting and real-time dashboard updates.

- **[DeepEval CI/CD Framework](https://github.com/confident-ai/deepeval)** - Pytest integration for seamless testing with automated regression detection and comprehensive test reporting.

### Production Monitoring

- **[Arize Phoenix](https://github.com/Arize-ai/phoenix)** - Open-source observability tool for LLM applications with trace logging, pre-configured evaluation templates, and community tool integration.


## Getting Started

### For Red Team Operations
1. Start with **DeepTeam** or **PyRIT** for comprehensive attack frameworks
2. Use **JailbreakBench** for standardized jailbreak evaluation
3. Implement **promptmap2** for automated vulnerability scanning
4. Leverage **Spikee** for specialized prompt injection testing

### For Blue Team Defense
1. Deploy **Guardrails AI** or **NeMo Guardrails** for real-time protection
2. Implement **LLM Guard** for comprehensive security scanning
3. Use **DeepEval** for ongoing safety evaluation
4. Add **Rebuff** for prompt injection detection

### For Purple Team Integration
1. Combine **PromptFoo** for adaptive red teaming with **DeepEval** for comprehensive evaluation
2. Use **CyberSecEval** for standardized security benchmarking
3. Implement continuous monitoring with **Arize Phoenix** or **Evidently AI**
4. Integrate CI/CD security testing with framework-specific tools

## Contributing

We welcome contributions! Please see our [contributing guidelines](CONTRIBUTING.md) for details on:

- Adding new tools and resources
- Updating existing entries
- Reporting issues or broken links
- Suggesting new categories or improvements

### Contribution Criteria

Tools and resources should meet the following criteria:
- **Open Source**: Publicly available code or freely accessible resources
- **LLM-Specific**: Designed specifically for LLM security (not general AI/ML security)
- **Actively Maintained**: Updated within the last 12 months
- **Documented**: Clear documentation and usage instructions
- **Practical**: Suitable for real-world security testing and evaluation

## License

This list is licensed under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) - feel free to use, modify, and distribute.

## Acknowledgments

Special thanks to the security research community, OWASP LLM project contributors, and all the tool maintainers making LLM security more accessible and robust.

---

**Disclaimer**: These tools are provided for educational and legitimate security testing purposes. Always ensure you have proper authorization before testing systems you do not own. The maintainers are not responsible for any misuse of the tools listed here.

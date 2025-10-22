# 🧠 RISC-V 기반 CPU 설계 프로젝트

## 📌 프로젝트 목표
이 프로젝트는 **RISC-V ISA 기반의 32비트 단일 사이클 CPU (RV32I)** 를 설계하고,  
각 명령어 타입의 동작을 **시뮬레이션 파형으로 검증**하기 위해 진행되었습니다.  
CPU 내부의 데이터 경로와 제어 신호 흐름을 직접 설계하며,  
구조와 동작 원리를 이해하는 것을 목표로 진행되었습니다.

---

## ⚙️ 개발 환경
- **언어:** SystemVerilog  
- **개발 도구:** Vivado, Visual Studio Code
- **CPU 아키텍처:** RV32I (Based on RISC-V)  
- **형태:** Single Cycle

---

## 🧩 구성 블록
| 블록 이름 | 역할 |
|------------|------|
| **Control Unit** | 명령어 해독 및 제어 신호 생성 |
| **Instruction Memory (ROM)** | 실행할 명령어 저장 |
| **Data Memory (RAM)** | 연산 중 필요한 데이터 저장 |
| **Register File** | 연산용 데이터 및 결과 임시 저장 |
| **ALU** | 산술 및 논리 연산 수행 |
| **Immediate Extend** | 명령어의 즉시값 비트 확장 |
| **Program Counter (PC)** | 다음 실행 명령어 주소 결정 |

### 블록 다이어그램
<img width="1736" height="1442" alt="rv32i drawio" src="https://github.com/user-attachments/assets/5df3154c-f3c4-4e62-abb8-101672ca3be7" />

---

## 🧮 지원 명령어 타입 및 주요 기능
- **R-Type:** 레지스터 간 산술/논리 연산  
- **I-Type:** 레지스터와 즉시값 간 연산  
- **S-Type:** 메모리에 데이터 저장  
- **IL-Type (Load):** 메모리에서 데이터 읽기  
- **U-Type:** 상위 20비트 즉시값 로드  
- **B/J-Type:** 분기 및 점프 제어  

---

## 📈 프로젝트 고찰
RISC-V기반의 single cylce CPU가 어떤식으로 구성되어있고, 어떻게 동작하는지 직접 설계하고 구현하면서 확인할 수 있었습니다. 또한 이 과정을 통해 CPU내부의 데이터경로와 제어 신호 흐름에 대한 이해를 높힐 수 있었습니다. 향후 **멀티사이클(Multi-Cycle)** 및 **파이프라인(Pipeline)** 구조 설계로 확장 하여 설계하는 것을 다음 목표로 하고 있습니다.

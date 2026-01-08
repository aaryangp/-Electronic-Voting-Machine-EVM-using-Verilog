# 🗳️ Electronic Voting Machine (EVM) using FSM (Verilog)

This project implements a **secure Electronic Voting Machine (EVM)** using a **Finite State Machine (FSM)** in **Verilog HDL**.  
The design ensures **one vote per voter**, prevents **double voting**, and maintains **accurate vote counts** for multiple candidates.

---

## 🧠 Design Overview

The EVM works as a **controller FSM** that manages voter flow and vote counting.  
Each voter is allowed to cast **exactly one vote**, after which the system is locked until an admin enables the next voter.

---

## 🔁 FSM States

| State | Description |
|-----|------------|
| `IDLE` | Waiting for admin to start voting |
| `READY` | Voter can select a candidate |
| `VOTE_CAST` | Vote is recorded (1 clock cycle) |
| `LOCKED` | Machine locked until next voter |

---

## 🔁 State Transition Table

| Current State | Condition | Next State | Action |
|--------------|----------|------------|--------|
| IDLE | `start_vote = 1` | READY | Enable voting |
| READY | `confirm = 1` & `vote_btn ≠ 0` | VOTE_CAST | Prepare to record vote |
| VOTE_CAST | (automatic) | LOCKED | Increment vote count |
| LOCKED | `next_voter = 1` | READY | Allow next voter |
| Any | `rst = 1` | IDLE | Reset election |

---

## 📥 Inputs

| Signal | Width | Description |
|------|------|-------------|
| `clk` | 1 | System clock |
| `rst` | 1 | Active-high reset (new election) |
| `start_vote` | 1 | Admin enables voting |
| `next_voter` | 1 | Admin allows next voter |
| `vote_btn` | 4 | One-hot vote buttons |
| `confirm` | 1 | Confirms selected vote |

---

## 📤 Outputs

| Signal | Width | Description |
|------|------|-------------|
| `vote_count_A` | 4 | Votes for Candidate A |
| `vote_count_B` | 4 | Votes for Candidate B |
| `vote_count_C` | 4 | Votes for Candidate C |
| `vote_count_D` | 4 | Votes for Candidate D |

---

## 🧮 Vote Counting Logic

- Votes are counted **only in the `VOTE_CAST` state**
- `VOTE_CAST` lasts **exactly one clock cycle**
- Only **one-hot inputs** (`0001`, `0010`, `0100`, `1000`) are accepted
- Invalid inputs (`0000`, multiple buttons) are ignored

This guarantees **no double voting**.

---

## 🔐 How Double Voting is Prevented

✔ Vote counters update in **only one FSM state**  
✔ FSM transitions to `LOCKED` immediately after voting  
✔ Buttons and confirm signals are ignored in `LOCKED`  
✔ Next vote requires explicit `next_voter` signal  

> **If a vote can be counted in only one state, and that state occurs once per voter, double voting is impossible.**

---

## 🧪 Testbench

The testbench:
- Generates a clock
- Applies reset correctly
- Simulates multiple voters using a task
- Uses clean **1-clock pulses**
- Monitors vote counts
- Dumps waveform (`EVM.vcd`) for GTKWave

### Expected Final Counts (Testbench)

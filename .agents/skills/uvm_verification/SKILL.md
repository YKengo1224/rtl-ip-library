---
name: uvm_verification
description: SystemVerilogのRTLシミュレーション用にUVMテストベンチを構築したり、SystemVerilog Assertions (SVA) を記述する際のガイドライン。
---

# Verification Standards

## 1. UVM Architecture
- RTLのシミュレーションコード（テストベンチ）には必ずUVMを使用すること。
- ScoreboardやSequenceなど、UVMのクラスベースのコンポーネント構造を遵守すること。
- uvm_testは一つしか作らず、uvm_seqnenceのみをテストケースごとに作成する
- test case(uvm_sequenceは、tb_seq_baseを継承して作成すること)
- rtl-ip-librar/uvmの各ファイルを基本とすること

## 2. dlirectory構造
- rtl-ip-librar/uvmを基本構造とすること 

## 3. Automation
- シミュレーションの実行（xsimやDSimなど）を想定し、Pythonスクリプトによるテストの自動化やログ解析と親和性の高い構造・出力形式を維持すること。

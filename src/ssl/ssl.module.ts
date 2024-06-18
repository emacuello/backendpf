import { Module } from '@nestjs/common';
import { SslController } from './ssl.controller';

@Module({
  imports: [],
  controllers: [SslController],
  providers: [],
})
export class SslModule {}

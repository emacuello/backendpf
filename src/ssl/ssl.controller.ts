import { Controller, Get, Res } from '@nestjs/common';
import { Response } from 'express';
import { join } from 'path';

@Controller('.well-known/pki-validation')
export class SslController {
  constructor() {}

  @Get('FF919A67B5BADFF5D43EAC35F14B0955.txt')
  findAll(@Res() res: Response) {
    const filePath = join(
      __dirname,
      '..',
      '..',
      '.well-known',
      'pki-validation',
      'FF919A67B5BADFF5D43EAC35F14B0955.txt',
    );
    return res.sendFile(filePath);
  }
}
